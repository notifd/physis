# Grasses — L-system grass models
#
# References:
# - ABOP §1.5 Fig 1.24 branching structure variants
# - Prusinkiewicz & Lindenmayer, narrow-angle branching for grass-like forms

# 1. Wheat — single stem with head
register_species!(LSystemDef(
    name = "Wheat",
    category = :grasses,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]F[+X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 12.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24 variants; narrow-angle branching",
        :tropism => :gravitropism,
        :linecolor => "#d4a017",
        :linewidth => 0.8,
        :rule_notation => "X -> F[-X]F[+X]X, F -> FF",
    ),
))

# 2. Bamboo — segmented upright growth
register_species!(LSystemDef(
    name = "Bamboo",
    category = :grasses,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("FF[+F][-F]")),
    ]),
    generations = 5,
    angle = 15.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24 variants; segmented branching",
        :linecolor => "#2ecc71",
        :linewidth => 1.2,
        :rule_notation => "F -> FF[+F][-F]",
    ),
))

# 3. Pampas Grass — dense tufted form
register_species!(LSystemDef(
    name = "Pampas Grass",
    category = :grasses,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 8.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24 variants; dense narrow-angle branching",
        :linecolor => "#ecf0f1",
        :linewidth => 0.6,
        :rule_notation => "X -> F[+X][-X]FX, F -> FF",
    ),
))

# 4. Fountain Grass — arching blades
register_species!(LSystemDef(
    name = "Fountain Grass",
    category = :grasses,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]+F[+X]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 10.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24 variants; arching growth form",
        :tropism => :gravitropism,
        :linecolor => "#a0522d",
        :linewidth => 0.8,
        :rule_notation => "X -> F[-X]+F[+X]-X, F -> FF",
    ),
))

# 5. Blue Fescue — compact mounding
register_species!(LSystemDef(
    name = "Blue Fescue",
    category = :grasses,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 15.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24 variants; compact mounding form",
        :linecolor => "#5dade2",
        :linewidth => 0.6,
        :rule_notation => "X -> F[+X]F[-X]+X, F -> FF",
    ),
))
