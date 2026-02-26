using StableRNGs

@testset "Rules" begin
    @testset "Rule (D0L)" begin
        @testset "Construction" begin
            # F → F+F
            r = Rule(LSymbol('F'), LString("F+F"))
            @test r.lhs == LSymbol('F')
            @test r.rhs == LString("F+F")
        end

        @testset "Identity-like rule" begin
            # A → A (valid, even if a no-op)
            r = Rule(LSymbol('A'), LString("A"))
            @test r.lhs == LSymbol('A')
            @test length(r.rhs) == 1
        end

        @testset "Rule to empty RHS" begin
            # A → ε (symbol deletion)
            r = Rule(LSymbol('A'), LString(AbstractSymbol[]))
            @test isempty(r.rhs)
        end
    end

    @testset "ParametricRule" begin
        @testset "Construction with condition and production" begin
            # A(x) : x > 0 → F A(x-1)
            lhs = ParametricSymbol('A', (0.0,))
            condition = (x,) -> x > 0
            production = (x,) -> AbstractSymbol[LSymbol('F'), ParametricSymbol('A', (x - 1,))]

            r = ParametricRule(lhs, condition, production)
            @test name(r.lhs) == 'A'
            @test arity(r.lhs) == 1
        end

        @testset "Default condition (always true)" begin
            lhs = ParametricSymbol('A', (0.0,))
            production = (x,) -> AbstractSymbol[LSymbol('F')]
            r = ParametricRule(lhs, production)
            @test r.condition(999.0)  # always true
            @test r.condition(-1.0)   # always true
        end

        @testset "Condition filtering" begin
            lhs = ParametricSymbol('A', (0.0,))
            cond_pos = (x,) -> x > 0
            prod_pos = (x,) -> AbstractSymbol[LSymbol('F'), ParametricSymbol('A', (x - 1,))]

            r = ParametricRule(lhs, cond_pos, prod_pos)
            @test r.condition(5.0)
            @test !r.condition(-1.0)
            @test !r.condition(0.0)
        end

        @testset "Multi-parameter rule" begin
            # B(x, y) : x > y → F
            lhs = ParametricSymbol('B', (0.0, 0.0))
            condition = (x, y) -> x > y
            production = (x, y) -> AbstractSymbol[LSymbol('F')]

            r = ParametricRule(lhs, condition, production)
            @test arity(r.lhs) == 2
            @test r.condition(5.0, 3.0)
            @test !r.condition(1.0, 3.0)
        end
    end

    @testset "StochasticRule" begin
        @testset "Construction" begin
            lhs = LSymbol('F')
            weights = [0.5, 0.5]
            alts = [LString("F+F"), LString("F-F")]

            r = StochasticRule(lhs, weights, alts)
            @test r.lhs == LSymbol('F')
            @test length(r.alternatives) == 2
            @test r.weights == [0.5, 0.5]
        end

        @testset "Requires at least 2 alternatives" begin
            @test_throws ArgumentError StochasticRule(
                LSymbol('F'), [1.0], [LString("F+F")]
            )
        end

        @testset "Requires positive weights" begin
            @test_throws ArgumentError StochasticRule(
                LSymbol('F'), [0.5, -0.1], [LString("F+F"), LString("F-F")]
            )
        end

        @testset "Requires matching weight and alternative counts" begin
            @test_throws ArgumentError StochasticRule(
                LSymbol('F'), [0.5, 0.3, 0.2], [LString("F+F"), LString("F-F")]
            )
        end

        @testset "Unnormalized weights are valid" begin
            r = StochasticRule(
                LSymbol('F'), [2.0, 3.0], [LString("F+F"), LString("F-F")]
            )
            @test r.weights == [2.0, 3.0]
        end
    end

    @testset "RuleSet" begin
        @testset "Construction from rules" begin
            r1 = Rule(LSymbol('A'), LString("AB"))
            r2 = Rule(LSymbol('B'), LString("A"))

            rs = RuleSet([r1, r2])
            @test rs isa RuleSet
        end

        @testset "Empty RuleSet" begin
            rs = RuleSet(AbstractRule[])
            @test rs isa RuleSet
        end

        @testset "Mixed rule types" begin
            d0l = Rule(LSymbol('F'), LString("FF"))

            lhs = ParametricSymbol('A', (0.0,))
            para = ParametricRule(lhs, (x,) -> AbstractSymbol[LSymbol('F')])

            rs = RuleSet(AbstractRule[d0l, para])
            @test rs isa RuleSet
        end

        @testset "Rejects mixing StochasticRule with other types for same char" begin
            d0l = Rule(LSymbol('F'), LString("FF"))
            stoch = StochasticRule(LSymbol('F'), [0.5, 0.5], [LString("F+F"), LString("F-F")])

            @test_throws ArgumentError RuleSet(AbstractRule[d0l, stoch])
        end
    end
end
