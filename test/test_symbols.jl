@testset "Symbols" begin
    @testset "Plain LSymbol creation" begin
        f = LSymbol('F')
        @test name(f) == 'F'

        plus = LSymbol('+')
        @test name(plus) == '+'
    end

    @testset "Plain LSymbol equality and hashing" begin
        a = LSymbol('A')
        a2 = LSymbol('A')
        b = LSymbol('B')

        @test a == a2
        @test a != b
        @test hash(a) == hash(a2)
        @test hash(a) != hash(b)
    end

    @testset "Plain LSymbol show" begin
        f = LSymbol('F')
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
        f1 = LSymbol('F')
        f2 = LSymbol('F')
        g = LSymbol('G')

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
        plain_a = LSymbol('A')
        @test !matches(plain_a, pa1)
        @test !matches(pa1, plain_a)
    end
end

@testset "LString" begin
    @testset "Construction from symbols" begin
        f = LSymbol('F')
        plus = LSymbol('+')
        ls = LString([f, plus, f])

        @test length(ls) == 3
        @test ls[1] == f
        @test ls[2] == plus
        @test ls[3] == f
    end

    @testset "Construction from string" begin
        ls = LString("F+F-F")
        @test length(ls) == 5
        @test ls[1] == LSymbol('F')
        @test ls[3] == LSymbol('F')
        @test ls[2] == LSymbol('+')
        @test ls[4] == LSymbol('-')
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

    @testset "Iterator traits" begin
        @test Base.IteratorSize(LString) == Base.HasLength()
        @test Base.IteratorEltype(LString) == Base.HasEltype()
        @test eltype(LString) == AbstractSymbol
    end

    @testset "Copy independence" begin
        ls1 = LString("FG")
        ls2 = copy(ls1)
        @test ls1 == ls2
        # Mutating the internal vector of one must not affect the other
        push!(ls2.symbols, LSymbol('+'))
        @test length(ls1) == 2
        @test length(ls2) == 3
    end

    @testset "Mixed parametric and plain symbols" begin
        syms = AbstractSymbol[
            LSymbol('F'),
            ParametricSymbol('A', (10.0,)),
            LSymbol('+'),
            ParametricSymbol('B', (1.0, 2.0)),
        ]
        ls = LString(syms)
        @test length(ls) == 4
        @test ls[1] isa LSymbol
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
            LSymbol('F'),
            ParametricSymbol('A', (10.0,)),
        ]
        ls2 = LString(syms)
        @test sprint(show, ls2) == "FA(10.0)"
    end

    @testset "Slicing" begin
        ls = LString("ABCDE")
        sub = ls[2:4]
        @test length(sub) == 3
        @test sub[1] == LSymbol('B')
        @test sub[3] == LSymbol('D')
    end
end
