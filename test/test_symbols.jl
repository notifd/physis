@testset "Symbols" begin
    @testset "Plain Symbol creation" begin
        f = Physis.Symbol('F')
        @test name(f) == 'F'

        plus = Physis.Symbol('+')
        @test name(plus) == '+'
    end

    @testset "Plain Symbol equality and hashing" begin
        a = Physis.Symbol('A')
        a2 = Physis.Symbol('A')
        b = Physis.Symbol('B')

        @test a == a2
        @test a != b
        @test hash(a) == hash(a2)
        @test hash(a) != hash(b)
    end

    @testset "Plain Symbol show" begin
        f = Physis.Symbol('F')
        @test sprint(show, f) == "F"
    end

    @testset "ParametricSymbol creation" begin
        a = ParametricSymbol('A', (10.0,))
        @test name(a) == 'A'
        @test arity(a) == 1
        @test params(a) == (10.0,)

        b = ParametricSymbol('B', (1.0, 2.0, 3.0))
        @test name(b) == 'B'
        @test arity(b) == 3
        @test params(b) == (1.0, 2.0, 3.0)
    end

    @testset "ParametricSymbol from varargs" begin
        a = ParametricSymbol('A', 10.0)
        @test arity(a) == 1
        @test params(a) == (10.0,)

        b = ParametricSymbol('B', 1.0, 2.0)
        @test arity(b) == 2
        @test params(b) == (1.0, 2.0)
    end

    @testset "ParametricSymbol from integers (Real conversion)" begin
        a = ParametricSymbol('A', 10)
        @test params(a) == (10.0,)

        b = ParametricSymbol('B', 1, 2, 3)
        @test params(b) == (1.0, 2.0, 3.0)
    end

    @testset "ParametricSymbol equality" begin
        a1 = ParametricSymbol('A', (5.0,))
        a2 = ParametricSymbol('A', (5.0,))
        a3 = ParametricSymbol('A', (7.0,))
        b1 = ParametricSymbol('B', (5.0,))

        @test a1 == a2
        @test a1 != a3   # same char, different params
        @test a1 != b1   # different char

        # Different arity → not equal
        a_two = ParametricSymbol('A', (5.0, 1.0))
        @test a1 != a_two
    end

    @testset "ParametricSymbol show" begin
        a = ParametricSymbol('A', (10.0, 3.5))
        @test sprint(show, a) == "A(10.0, 3.5)"
    end

    @testset "matches()" begin
        f1 = Physis.Symbol('F')
        f2 = Physis.Symbol('F')
        g = Physis.Symbol('G')

        @test matches(f1, f2)
        @test !matches(f1, g)

        # Parametric: same char + arity → match regardless of values
        pa1 = ParametricSymbol('A', (1.0,))
        pa2 = ParametricSymbol('A', (99.0,))
        @test matches(pa1, pa2)

        # Different arity → no match
        pa3 = ParametricSymbol('A', (1.0, 2.0))
        @test !matches(pa1, pa3)

        # Different types → no match
        plain_a = Physis.Symbol('A')
        @test !matches(plain_a, pa1)
        @test !matches(pa1, plain_a)
    end
end

@testset "LString" begin
    @testset "Construction from symbols" begin
        f = Physis.Symbol('F')
        plus = Physis.Symbol('+')
        ls = LString([f, plus, f])

        @test length(ls) == 3
        @test ls[1] == f
        @test ls[2] == plus
        @test ls[3] == f
    end

    @testset "Construction from string" begin
        ls = LString("F+F-F")
        @test length(ls) == 5
        @test ls[1] == Physis.Symbol('F')
        @test ls[3] == Physis.Symbol('F')
        @test ls[2] == Physis.Symbol('+')
        @test ls[4] == Physis.Symbol('-')
    end

    @testset "Iteration" begin
        ls = LString("ABC")
        chars = [name(s) for s in ls]
        @test chars == ['A', 'B', 'C']
    end

    @testset "Empty LString" begin
        ls = LString(AbstractSymbol[])
        @test isempty(ls)
        @test length(ls) == 0
    end

    @testset "Push and append" begin
        ls = LString("F")
        push!(ls, Physis.Symbol('+'))
        @test length(ls) == 2
        @test ls[2] == Physis.Symbol('+')

        ls2 = LString("-F")
        append!(ls, ls2)
        @test length(ls) == 4
    end

    @testset "Mixed parametric and plain symbols" begin
        syms = AbstractSymbol[
            Physis.Symbol('F'),
            ParametricSymbol('A', (10.0,)),
            Physis.Symbol('+'),
            ParametricSymbol('B', (1.0, 2.0)),
        ]
        ls = LString(syms)
        @test length(ls) == 4
        @test ls[1] isa Physis.Symbol
        @test ls[2] isa ParametricSymbol
        @test arity(ls[2]) == 1
        @test ls[4] isa ParametricSymbol
        @test arity(ls[4]) == 2
    end

    @testset "Equality" begin
        ls1 = LString("F+F")
        ls2 = LString("F+F")
        ls3 = LString("F-F")

        @test ls1 == ls2
        @test ls1 != ls3
    end

    @testset "Show" begin
        ls = LString("F+F")
        @test sprint(show, ls) == "F+F"

        # With parametric symbols
        syms = AbstractSymbol[
            Physis.Symbol('F'),
            ParametricSymbol('A', (10.0,)),
        ]
        ls2 = LString(syms)
        @test sprint(show, ls2) == "FA(10.0)"
    end

    @testset "Slicing" begin
        ls = LString("ABCDE")
        sub = ls[2:4]
        @test length(sub) == 3
        @test sub[1] == Physis.Symbol('B')
        @test sub[3] == Physis.Symbol('D')
    end
end
