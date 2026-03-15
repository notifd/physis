# Succulents — L-system succulent plant models
#
# References:
# - Douady & Couder (1992), "Phyllotaxis as a Physical Self-Organized Growth Process"
# - ABOP §1.5 branching structure variants
# - Golden angle (137.5 deg) for phyllotactic rosette forms

# 1. Aloe Vera — rosette of thick leaves
register_species!(LSystemDef(
    name = "Aloe Vera",
    category = :succulents,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]F")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 137.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Douady & Couder 1992; phyllotactic rosette model",
        :use_phyllotaxis => true,
        :linecolor => "#27ae60",
        :linewidth => 1.5,
        :rule_notation => "X -> F[+X][-X]F, F -> FF",
    ),
))

# 2. Agave — large rosette
register_species!(LSystemDef(
    name = "Agave",
    category = :succulents,
    axiom = LString("A"),
    rules = RuleSet([
        Rule(LSymbol('A'), LString("F[+A][-A]FA")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 137.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Douady & Couder 1992; large rosette phyllotaxis",
        :use_phyllotaxis => true,
        :linecolor => "#1abc9c",
        :linewidth => 1.8,
        :rule_notation => "A -> F[+A][-A]FA, F -> FF",
    ),
))

# 3. Jade Plant — thick branching
register_species!(LSystemDef(
    name = "Jade Plant",
    category = :succulents,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X][+X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 45.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.5 branching variants; wide-angle succulent branching",
        :linecolor => "#2ecc71",
        :linewidth => 2.0,
        :rule_notation => "X -> F[-X][+X]FX, F -> FF",
    ),
))

# 4. Echeveria — compact spiral rosette
register_species!(LSystemDef(
    name = "Echeveria",
    category = :succulents,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 137.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Douady & Couder 1992; compact spiral rosette",
        :use_phyllotaxis => true,
        :linecolor => "#8e44ad",
        :linewidth => 1.2,
        :rule_notation => "X -> F[+X]F[-X]X, F -> FF",
    ),
))

# 5. Prickly Pear — pad-like branching
register_species!(LSystemDef(
    name = "Prickly Pear",
    category = :succulents,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.5 branching variants; orthogonal pad-like branching",
        :linecolor => "#16a085",
        :linewidth => 2.0,
        :rule_notation => "X -> F[+X]F[-X], F -> FF",
    ),
))
