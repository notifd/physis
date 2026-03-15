# Vines — L-system vine and climbing plant models
#
# References:
# - Bell 1991, "Plant Form: An Illustrated Guide to Flowering Plant Morphology"
# - ABOP Ch. 4, "Phyllotaxis and branching patterns"

# 1. Ivy — climbing with aerial roots
register_species!(LSystemDef(
    name = "Ivy",
    category = :vines,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]+F[+X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bell 1991; ABOP Ch. 4",
        :linecolor => "#27ae60",
        :linewidth => 1.2,
        :rule_notation => "X -> F[-X]+F[+X]X, F -> FF",
    ),
))

# 2. Grape Vine — tendril-bearing climber
register_species!(LSystemDef(
    name = "Grape Vine",
    category = :vines,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bell 1991; ABOP Ch. 4",
        :linecolor => "#6c3483",
        :linewidth => 1.5,
        :rule_notation => "X -> F[+X]F[-X]+X, F -> FF",
    ),
))

# 3. Wisteria — cascading pendulous growth
register_species!(LSystemDef(
    name = "Wisteria",
    category = :vines,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]F[+X]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bell 1991; ABOP Ch. 4",
        :linecolor => "#8e44ad",
        :linewidth => 1.3,
        :rule_notation => "X -> F[-X]F[+X]-X, F -> FF",
    ),
))

# 4. Morning Glory — twining stem
register_species!(LSystemDef(
    name = "Morning Glory",
    category = :vines,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 35.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bell 1991; ABOP Ch. 4",
        :linecolor => "#3498db",
        :linewidth => 1.2,
        :rule_notation => "X -> F[+X][-X]FX, F -> FF",
    ),
))

# 5. Clematis — leaf-climbing vine
register_species!(LSystemDef(
    name = "Clematis",
    category = :vines,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X][+X]")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 28.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bell 1991; ABOP Ch. 4",
        :linecolor => "#e74c3c",
        :linewidth => 1.3,
        :rule_notation => "X -> F[+X]F[-X][+X], F -> FF",
    ),
))
