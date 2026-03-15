"""
Tests for Context-Sensitive L-Systems (Phase 0).

Tests that:
1. Left-only context rules fire correctly
2. Right-only context rules fire correctly
3. Both-context rules fire correctly
4. Bracket transparency works (skips [...] during context scanning)
5. No-match cases leave symbol unchanged
6. Mixed RuleSet (ContextRule + regular Rule) works
7. Multiple generations with context rules
8. Identity: no matching rule → symbol passes through

Reference: ABOP §1.6–1.7
"""

using StableRNGs

@testset "Context-Sensitive L-Systems" begin

    @testset "Left-only context" begin
        # A < B → C  (B becomes C only when preceded by A)
        rules = RuleSet([
            ContextRule('A', LSymbol('B'), nothing, LString("C"))
        ])

        # AB → AC (B after A becomes C)
        result = rewrite_step(LString("AB"), rules)
        @test result == LString("AC")

        # BA → BA (B not preceded by A, no change)
        result2 = rewrite_step(LString("BA"), rules)
        @test result2 == LString("BA")

        # AAB → AAC (leftmost A is context for inner A? No — B preceded by A → C)
        result3 = rewrite_step(LString("AAB"), rules)
        @test result3 == LString("AAC")

        # B alone → B (no left context)
        result4 = rewrite_step(LString("B"), rules)
        @test result4 == LString("B")
    end

    @testset "Right-only context" begin
        # B > C → D  (B becomes D only when followed by C)
        rules = RuleSet([
            ContextRule(nothing, LSymbol('B'), 'C', LString("D"))
        ])

        # BC → DC
        result = rewrite_step(LString("BC"), rules)
        @test result == LString("DC")

        # BA → BA (B not followed by C)
        result2 = rewrite_step(LString("BA"), rules)
        @test result2 == LString("BA")

        # B alone → B
        result3 = rewrite_step(LString("B"), rules)
        @test result3 == LString("B")
    end

    @testset "Both contexts" begin
        # A < B > C → D  (B between A and C)
        rules = RuleSet([
            ContextRule('A', LSymbol('B'), 'C', LString("D"))
        ])

        # ABC → ADC
        result = rewrite_step(LString("ABC"), rules)
        @test result == LString("ADC")

        # ABX → ABX (right context doesn't match)
        result2 = rewrite_step(LString("ABX"), rules)
        @test result2 == LString("ABX")

        # XBC → XBC (left context doesn't match)
        result3 = rewrite_step(LString("XBC"), rules)
        @test result3 == LString("XBC")
    end

    @testset "Bracket transparency" begin
        # A < B → C  with brackets between A and B
        rules = RuleSet([
            ContextRule('A', LSymbol('B'), nothing, LString("C"))
        ])

        # A[+F]B → A[+F]C  (brackets are transparent, A is still left context of B)
        result = rewrite_step(LString("A[+F]B"), rules)
        @test result == LString("A[+F]C")

        # A[+F[-G]]B → A[+F[-G]]C  (nested brackets still transparent)
        result2 = rewrite_step(LString("A[+F[-G]]B"), rules)
        @test result2 == LString("A[+F[-G]]C")

        # Right context with bracket transparency
        # B > C → D
        rules2 = RuleSet([
            ContextRule(nothing, LSymbol('B'), 'C', LString("D"))
        ])

        # B[+F]C → D[+F]C  (B's right context skips [...], finds C)
        result3 = rewrite_step(LString("B[+F]C"), rules2)
        @test result3 == LString("D[+F]C")
    end

    @testset "No-match leaves symbol unchanged" begin
        # A < B → C
        rules = RuleSet([
            ContextRule('A', LSymbol('B'), nothing, LString("C"))
        ])

        # XBY → XBY (no A before B)
        result = rewrite_step(LString("XBY"), rules)
        @test result == LString("XBY")

        # String without B at all
        result2 = rewrite_step(LString("AXY"), rules)
        @test result2 == LString("AXY")
    end

    @testset "Mixed RuleSet (ContextRule + regular Rule)" begin
        rules = RuleSet([
            # Context rule: A < B → X
            ContextRule('A', LSymbol('B'), nothing, LString("X")),
            # Regular rule: C → D
            Rule(LSymbol('C'), LString("D")),
        ])

        # ABC → AXD (B after A becomes X, C becomes D)
        result = rewrite_step(LString("ABC"), rules)
        @test result == LString("AXD")

        # CBC → DBD (C→D, B not after A stays B, C→D)
        result2 = rewrite_step(LString("CBC"), rules)
        @test result2 == LString("DBD")
    end

    @testset "Multiple generations" begin
        # Signal propagation: A < B → A, starting with "ABBBBB"
        # Generation 0: A B B B B B
        # Generation 1: A A B B B B  (first B after A → A)
        # Generation 2: A A A B B B  (second B after A → A)
        # Generation 3: A A A A B B
        rules = RuleSet([
            ContextRule('A', LSymbol('B'), nothing, LString("A"))
        ])

        rng = StableRNG(42)
        gen0 = LString("ABBBBB")
        gen1 = rewrite_step(gen0, rules; rng=rng)
        @test gen1 == LString("AABBBB")

        gen2 = rewrite_step(gen1, rules; rng=rng)
        @test gen2 == LString("AAABBB")

        gen3 = derive(gen0, rules, 3; rng=rng)
        @test gen3 == LString("AAAABB")

        gen5 = derive(gen0, rules, 5; rng=rng)
        @test gen5 == LString("AAAAAA")
    end

    @testset "Context rule with multi-symbol replacement" begin
        # A < B → XY (replace B with two symbols)
        rules = RuleSet([
            ContextRule('A', LSymbol('B'), nothing, LString("XY"))
        ])

        result = rewrite_step(LString("AB"), rules)
        @test result == LString("AXY")
        @test length(result) == 3
    end

    @testset "Internal context functions" begin
        ls = LString("ABCDE")

        # _find_left_context at various positions
        @test Physis._find_left_context(ls, 1) === nothing  # nothing before A
        @test Physis._find_left_context(ls, 2) == 'A'       # A before B
        @test Physis._find_left_context(ls, 3) == 'B'       # B before C

        # _find_right_context
        @test Physis._find_right_context(ls, 5) === nothing  # nothing after E
        @test Physis._find_right_context(ls, 4) == 'E'       # E after D
        @test Physis._find_right_context(ls, 1) == 'B'       # B after A

        # Bracket transparency
        ls2 = LString("A[+F]B")
        @test Physis._find_left_context(ls2, 6) == 'A'  # A is left of B (skips [+F])
        @test Physis._find_right_context(ls2, 1) == 'B'  # B is right of A (skips [+F])
    end

    @testset "Edge cases" begin
        # Empty LString
        rules = RuleSet([
            ContextRule('A', LSymbol('B'), nothing, LString("C"))
        ])
        result = rewrite_step(LString(""), rules)
        @test result == LString("")

        # Single symbol
        result2 = rewrite_step(LString("B"), rules)
        @test result2 == LString("B")

        # Context rule where lhs is bracket symbol — unusual but shouldn't crash
        # (bracket symbols are typically not rewritten, but the rule should just not match)
    end

    @testset "Backward compatibility" begin
        # Regular rules still work when context rules are in the RuleSet
        rules = RuleSet([
            Rule(LSymbol('A'), LString("AB")),
            Rule(LSymbol('B'), LString("A")),
        ])

        # Algae system (ABOP §1.1) — must still work exactly as before
        result = derive(LString("A"), rules, 4)
        @test result == LString("ABAABABA")
    end
end
