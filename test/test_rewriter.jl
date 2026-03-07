using StableRNGs

@testset "Rewriter" begin
    @testset "apply_rule" begin
        @testset "D0L rule application" begin
            r = Rule(LSymbol('F'), LString("F+F"))
            result = apply_rule(r, LSymbol('F'))
            @test result == LString("F+F")
        end

        @testset "Parametric rule application" begin
            lhs = ParametricSymbol('A', (0.0,))
            production = (x,) -> AbstractSymbol[LSymbol('F'), ParametricSymbol('A', (x - 1,))]
            r = ParametricRule(lhs, (x,) -> x > 0, production)

            sym = ParametricSymbol('A', (3.0,))
            result = apply_rule(r, sym)
            @test length(result) == 2
            @test result[1] == LSymbol('F')
            @test result[2] == ParametricSymbol('A', (2.0,))
        end

        @testset "Stochastic rule application is reproducible" begin
            lhs = LSymbol('F')
            alts = [LString("F+F"), LString("F-F")]
            r = StochasticRule(lhs, [0.5, 0.5], alts)

            rng1 = StableRNG(42)
            rng2 = StableRNG(42)

            result1 = apply_rule(r, LSymbol('F'), rng1)
            result2 = apply_rule(r, LSymbol('F'), rng2)
            @test result1 == result2
        end
    end

    @testset "rewrite_step" begin
        @testset "Single D0L rule" begin
            # F → F+F
            rs = RuleSet([Rule(LSymbol('F'), LString("F+F"))])
            axiom = LString("F")

            gen1 = rewrite_step(axiom, rs)
            @test gen1 == LString("F+F")
        end

        @testset "Identity: unmatched symbols pass through" begin
            rs = RuleSet([Rule(LSymbol('A'), LString("AB"))])
            axiom = LString("A+")

            gen1 = rewrite_step(axiom, rs)
            # A → AB, + passes through
            @test length(gen1) == 3
            @test gen1[1] == LSymbol('A')
            @test gen1[2] == LSymbol('B')
            @test gen1[3] == LSymbol('+')
        end

        @testset "Empty axiom" begin
            rs = RuleSet([Rule(LSymbol('A'), LString("AB"))])
            empty = LString(AbstractSymbol[])

            result = rewrite_step(empty, rs)
            @test isempty(result)
        end

        @testset "Parametric rule in rewrite_step" begin
            # A(x) : x > 1 → F A(x-1)
            # A(x) : x ≤ 1 → F
            lhs = ParametricSymbol('A', (0.0,))
            r1 = ParametricRule(lhs, (x,) -> x > 1,
                (x,) -> AbstractSymbol[LSymbol('F'), ParametricSymbol('A', (x - 1,))])
            r2 = ParametricRule(lhs, (x,) -> x <= 1,
                (x,) -> AbstractSymbol[LSymbol('F')])

            rs = RuleSet(AbstractRule[r1, r2])
            axiom = LString([ParametricSymbol('A', (3.0,))])

            gen1 = rewrite_step(axiom, rs)
            @test length(gen1) == 2
            @test gen1[1] == LSymbol('F')
            @test gen1[2] == ParametricSymbol('A', (2.0,))
        end

        @testset "Stochastic rule in rewrite_step" begin
            alts = [LString("F+F"), LString("F-F")]
            r = StochasticRule(LSymbol('F'), [0.5, 0.5], alts)
            rs = RuleSet([r])

            rng1 = StableRNG(42)
            rng2 = StableRNG(42)

            result1 = rewrite_step(LString("F"), rs; rng=rng1)
            result2 = rewrite_step(LString("F"), rs; rng=rng2)
            @test result1 == result2
        end
    end

    @testset "derive" begin
        @testset "Algae D0L (ABOP §1.1)" begin
            # A → AB, B → A
            # Axiom: A
            # Expected lengths: 1, 2, 3, 5, 8 (Fibonacci)
            r1 = Rule(LSymbol('A'), LString("AB"))
            r2 = Rule(LSymbol('B'), LString("A"))
            rs = RuleSet([r1, r2])
            axiom = LString("A")

            # Generation 0 = axiom
            @test derive(axiom, rs, 0) == LString("A")

            # Verify Fibonacci length sequence
            gen1 = derive(axiom, rs, 1)
            @test gen1 == LString("AB")
            @test length(gen1) == 2

            gen2 = derive(axiom, rs, 2)
            @test gen2 == LString("ABA")
            @test length(gen2) == 3

            gen3 = derive(axiom, rs, 3)
            @test gen3 == LString("ABAAB")
            @test length(gen3) == 5

            gen4 = derive(axiom, rs, 4)
            @test gen4 == LString("ABAABABA")
            @test length(gen4) == 8
        end

        @testset "n=0 returns axiom unchanged" begin
            rs = RuleSet([Rule(LSymbol('A'), LString("AB"))])
            axiom = LString("A")
            @test derive(axiom, rs, 0) == axiom
        end

        @testset "Negative n throws ArgumentError" begin
            rs = RuleSet([Rule(LSymbol('A'), LString("AB"))])
            axiom = LString("A")
            @test_throws ArgumentError derive(axiom, rs, -1)
        end

        @testset "Empty axiom derives to empty" begin
            rs = RuleSet([Rule(LSymbol('A'), LString("AB"))])
            empty = LString(AbstractSymbol[])
            @test derive(empty, rs, 5) == empty
        end

        @testset "Parametric derivation" begin
            # A(x) : x > 0 → F A(x-1)
            # A(x) : x ≤ 0 → F
            lhs = ParametricSymbol('A', (0.0,))
            r1 = ParametricRule(lhs, (x,) -> x > 0,
                (x,) -> AbstractSymbol[LSymbol('F'), ParametricSymbol('A', (x - 1,))])
            r2 = ParametricRule(lhs, (x,) -> x <= 0,
                (x,) -> AbstractSymbol[LSymbol('F')])

            rs = RuleSet(AbstractRule[r1, r2])
            axiom = LString([ParametricSymbol('A', (3.0,))])

            # A(3) → F A(2) → F F A(1) → F F F A(0) → F F F F
            result = derive(axiom, rs, 4)
            @test length(result) == 4
            @test all(s -> s == LSymbol('F'), result)
        end

        @testset "Stochastic derivation reproducibility" begin
            alts = [LString("FA"), LString("GA")]
            r = StochasticRule(LSymbol('A'), [0.5, 0.5], alts)
            rs = RuleSet([r])
            axiom = LString("A")

            # Same seed → same result
            result1 = derive(axiom, rs, 3; rng=StableRNG(123))
            result2 = derive(axiom, rs, 3; rng=StableRNG(123))
            @test result1 == result2

            # Different seeds → deterministically different results
            result_a = derive(axiom, rs, 1; rng=StableRNG(42))
            result_b = derive(axiom, rs, 1; rng=StableRNG(3))
            @test result_a == LString("GA")
            @test result_b == LString("FA")
            @test result_a != result_b
        end
    end
end
