# Aquatic — L-system aquatic plant models
#
# References:
# - Prusinkiewicz 1986, "Graphical applications of L-systems"
# - Aquatic plant branching morphology and hydrotropism

# 1. Water Lily — floating pad with branching roots
register_species!(LSystemDef(
    name = "Water Lily",
    category = :aquatic,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1986",
        :tropism => :hydrotropism,
        :linecolor => "#2ecc71",
        :linewidth => 1.5,
        :rule_notation => "X -> F[+X][-X]FX, F -> FF",
    ),
))

# 2. Seaweed — undulating strands
register_species!(LSystemDef(
    name = "Seaweed",
    category = :aquatic,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]F[+X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1986",
        :linecolor => "#1abc9c",
        :linewidth => 1.2,
        :rule_notation => "X -> F[-X]F[+X]X, F -> FF",
    ),
))

# 3. Kelp — tall blade-like growth
register_species!(LSystemDef(
    name = "Kelp",
    category = :aquatic,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("FF[+F][-F]")),
    ]),
    generations = 5,
    angle = 15.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1986",
        :linecolor => "#27ae60",
        :linewidth => 1.8,
        :rule_notation => "F -> FF[+F][-F]",
    ),
))

# 4. Duckweed — small floating rosettes
register_species!(LSystemDef(
    name = "Duckweed",
    category = :aquatic,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 45.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1986",
        :linecolor => "#16a085",
        :linewidth => 1.0,
        :rule_notation => "X -> F[+X]F[-X], F -> FF",
    ),
))

# 5. Lotus — elegant aquatic flower form
register_species!(LSystemDef(
    name = "Lotus",
    category = :aquatic,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]F[+X]")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 36.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Prusinkiewicz 1986",
        :linecolor => "#e91e63",
        :linewidth => 1.4,
        :rule_notation => "X -> F[+X][-X]F[+X], F -> FF",
    ),
))
