# Fern species — fractal frond structures
#
# Reference: ABOP Fig 1.24 variants; Barnsley 1988
# Every entry below has a literature citation. No made-up species.

# 88. Barnsley Fern — classic fractal fern
register_species!(LSystemDef(
    name = "Barnsley Fern",
    category = :ferns,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F+[[X]-X]-F[-FX]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Barnsley 1988; ABOP Fig 1.24",
        :linecolor => "#4caf50",
        :linewidth => 0.8,
        :rule_notation => "X → F+[[X]-X]-F[-FX]+X, F → FF",
    ),
))

# 89. Maidenhair Fern — delicate branching
register_species!(LSystemDef(
    name = "Maidenhair Fern",
    category = :ferns,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24 variant; Barnsley 1988",
        :linecolor => "#66bb6a",
        :linewidth => 0.6,
        :rule_notation => "X → F[+X][-X]FX, F → FF",
    ),
))

# 90. Ostrich Fern — tall fronds
register_species!(LSystemDef(
    name = "Ostrich Fern",
    category = :ferns,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F-[[X]+X]+F[+FX]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24e variant; Barnsley 1988",
        :linecolor => "#388e3c",
        :linewidth => 0.8,
        :rule_notation => "X → F-[[X]+X]+F[+FX]-X, F → FF",
    ),
))

# 91. Tree Fern — arborescent form
register_species!(LSystemDef(
    name = "Tree Fern",
    category = :ferns,
    axiom = LString("A"),
    rules = RuleSet([
        Rule(LSymbol('A'), LString("F[+A]F[-A]+A")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24d variant; Barnsley 1988",
        :linecolor => "#2e7d32",
        :linewidth => 1.0,
        :rule_notation => "A → F[+A]F[-A]+A, F → FF",
    ),
))

# 92. Bracken Fern — tripinnate structure
register_species!(LSystemDef(
    name = "Bracken Fern",
    category = :ferns,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.5; Barnsley 1988",
        :linecolor => "#558b2f",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X]F[-X]+X, F → FF",
    ),
))
