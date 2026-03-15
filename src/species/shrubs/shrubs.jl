# Shrubs — L-system shrub models
#
# References:
# - Honda & Fisher 1978, "Tree Branch Angle: Maximizing Effective Leaf Area"
# - ABOP §1.5 branching structure variants

# 1. Boxwood — dense compact branching
register_species!(LSystemDef(
    name = "Boxwood",
    category = :shrubs,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X][+X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Honda & Fisher 1978",
        :linecolor => "#2e7d32",
        :linewidth => 1.5,
        :rule_notation => "X -> F[-X][+X]FX, F -> FF",
    ),
))

# 2. Lilac — multi-stemmed arching
register_species!(LSystemDef(
    name = "Lilac",
    category = :shrubs,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Honda & Fisher 1978",
        :linecolor => "#9c27b0",
        :linewidth => 1.3,
        :rule_notation => "X -> F[+X]F[-X]+X, F -> FF",
    ),
))

# 3. Azalea — rounded form with dense branching
register_species!(LSystemDef(
    name = "Azalea",
    category = :shrubs,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]F[+X]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 28.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Honda & Fisher 1978",
        :linecolor => "#e91e63",
        :linewidth => 1.3,
        :rule_notation => "X -> F[-X]F[+X]-X, F -> FF",
    ),
))

# 4. Juniper Bush — spreading horizontal
register_species!(LSystemDef(
    name = "Juniper Bush",
    category = :shrubs,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Honda & Fisher 1978",
        :linecolor => "#1b5e20",
        :linewidth => 1.4,
        :rule_notation => "X -> F[+X][-X]FX, F -> FF",
    ),
))

# 5. Holly — pyramidal with stiff branches
register_species!(LSystemDef(
    name = "Holly",
    category = :shrubs,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]+F[+X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Honda & Fisher 1978",
        :linecolor => "#388e3c",
        :linewidth => 1.5,
        :rule_notation => "X -> F[-X]+F[+X]X, F -> FF",
    ),
))
