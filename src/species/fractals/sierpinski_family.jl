# Sierpinski Family — 8 Sierpinski-type L-systems
# Reference: ABOP §1.3

# 29. Sierpinski Triangle
register_species!(LSystemDef(
    name = "Sierpinski Triangle",
    category = :sierpinski_family,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("G-F-G")),
        Rule(LSymbol('G'), LString("F+G+F")),
    ]),
    generations = 6,
    angle = 60.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.3",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → G-F-G, G → F+G+F",
    ),
))

# 30. Sierpinski Arrowhead
register_species!(LSystemDef(
    name = "Sierpinski Arrowhead",
    category = :sierpinski_family,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("G+F+G")),
        Rule(LSymbol('G'), LString("F-G-F")),
    ]),
    generations = 7,
    angle = 60.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sierpinski arrowhead",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → G+F+G, G → F-G-F",
    ),
))

# 31. Sierpinski Square
register_species!(LSystemDef(
    name = "Sierpinski Square",
    category = :sierpinski_family,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F+F+F+F-F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sierpinski square curve",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → FF+F+F+F+F+F-F",
    ),
))

# 32. Sierpinski Carpet
register_species!(LSystemDef(
    name = "Sierpinski Carpet",
    category = :sierpinski_family,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F-F+F+F+F-F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sierpinski carpet variant",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F-F+F+F+F-F",
    ),
))

# 33. Sierpinski Hexagon
register_species!(LSystemDef(
    name = "Sierpinski Hexagon",
    category = :sierpinski_family,
    axiom = LString("F+F+F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 4,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sierpinski hexagonal variant",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F",
    ),
))

# 34. Sierpinski Median
register_species!(LSystemDef(
    name = "Sierpinski Median",
    category = :sierpinski_family,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("+G-F-G+")),
        Rule(LSymbol('G'), LString("-F+G+F-")),
    ]),
    generations = 8,
    angle = 60.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sierpinski median curve",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → +G-F-G+, G → -F+G+F-",
    ),
))

# 35. Sierpinski Pentagon
register_species!(LSystemDef(
    name = "Sierpinski Pentagon",
    category = :sierpinski_family,
    axiom = LString("F+F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 4,
    angle = 72.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sierpinski pentagonal variant",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F (72°)",
    ),
))

# 36. Sierpinski Maze
register_species!(LSystemDef(
    name = "Sierpinski Maze",
    category = :sierpinski_family,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F+F"))]),
    generations = 4,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sierpinski labyrinth",
        :linecolor => "#ff79c6",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F+F",
    ),
))
