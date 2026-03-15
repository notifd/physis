# Flowers — L-system flower models
#
# References:
# - Prusinkiewicz (1993), "Modeling of spatial structure and development of plants"
# - Vogel (1979), "A better model for the sunflower head" (phyllotaxis spiral)
# - ABOP §1.5 branching structure variants

# 1. Sunflower — tall stem with spiral head (phyllotaxis angle)
register_species!(LSystemDef(
    name = "Sunflower",
    category = :flowers,
    axiom = LString("A"),
    rules = RuleSet([
        Rule(LSymbol('A'), LString("F[+A][-A]FA")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 137.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Vogel 1979; Prusinkiewicz 1993",
        :has_flowers => true,
        :use_phyllotaxis => true,
        :linecolor => "#f1c40f",
        :linewidth => 1.2,
        :rule_notation => "A -> F[+A][-A]FA, F -> FF",
    ),
))

# 2. Wild Rose — branching with terminal flowers
register_species!(LSystemDef(
    name = "Wild Rose",
    category = :flowers,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1993; ABOP branching variants",
        :has_flowers => true,
        :linecolor => "#e74c3c",
        :linewidth => 1.0,
        :rule_notation => "X -> F[+X][-X]FX, F -> FF",
    ),
))

# 3. Dandelion — rosette pattern
register_species!(LSystemDef(
    name = "Dandelion",
    category = :flowers,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 36.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1993; ABOP §1.5 rosette variants",
        :linecolor => "#f39c12",
        :linewidth => 0.8,
        :rule_notation => "X -> F[+X]F[-X]+X, F -> FF",
    ),
))

# 4. Lily — symmetric petal arrangement
register_species!(LSystemDef(
    name = "Lily",
    category = :flowers,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]+F[+X]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1993; symmetric branching model",
        :has_flowers => true,
        :linecolor => "#ffffff",
        :linewidth => 1.0,
        :rule_notation => "X -> F[-X]+F[+X]-X, F -> FF",
    ),
))

# 5. Orchid — complex branching
register_species!(LSystemDef(
    name = "Orchid",
    category = :flowers,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X][+X]")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 28.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1993; complex branching model",
        :has_flowers => true,
        :linecolor => "#9b59b6",
        :linewidth => 1.0,
        :rule_notation => "X -> F[+X]F[-X][+X], F -> FF",
    ),
))
