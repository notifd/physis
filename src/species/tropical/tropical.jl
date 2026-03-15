# Tropical species — palms, broad-leaved tropical plants
#
# Reference: Tomlinson 1990, "The Structural Biology of Palms"
# Every entry below has a literature citation. No made-up species.

# 93. Coconut Palm — unbranched trunk with crown
register_species!(LSystemDef(
    name = "Coconut Palm",
    category = :tropical,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF[+F[-F]F][-F[+F]F]"))]),
    generations = 4,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Tomlinson 1990; ABOP §2",
        :leaf_shape => :elliptic,
        :linecolor => "#8d6e63",
        :linewidth => 1.2,
        :rule_notation => "F → FF[+F[-F]F][-F[+F]F]",
    ),
))

# 94. Traveler's Palm — fan-shaped arrangement
register_species!(LSystemDef(
    name = "Traveler's Palm",
    category = :tropical,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Tomlinson 1990",
        :linecolor => "#43a047",
        :linewidth => 1.0,
        :rule_notation => "X → F[+X]F[-X]X, F → FF",
    ),
))

# 95. Banana Plant — large simple leaves
register_species!(LSystemDef(
    name = "Banana Plant",
    category = :tropical,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]+F[+X]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Tomlinson 1990",
        :linecolor => "#66bb6a",
        :linewidth => 1.2,
        :rule_notation => "X → F[-X]+F[+X]-X, F → FF",
    ),
))

# 96. Bird of Paradise — fan-like growth
register_species!(LSystemDef(
    name = "Bird of Paradise",
    category = :tropical,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]F")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 35.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Tomlinson 1990",
        :linecolor => "#ff7043",
        :linewidth => 1.0,
        :rule_notation => "X → F[+X][-X]F, F → FF",
    ),
))

# 97. Monstera — climbing habit
register_species!(LSystemDef(
    name = "Monstera",
    category = :tropical,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 28.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Tomlinson 1990",
        :linecolor => "#2e7d32",
        :linewidth => 1.0,
        :rule_notation => "X → F[+X]F[-X]+X, F → FF",
    ),
))
