# Dragon Family — 8 dragon curve L-systems
# Reference: ABOP §1.3

# 21. Dragon Curve
register_species!(LSystemDef(
    name = "Dragon Curve",
    category = :dragon_family,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+G")),
        Rule(LSymbol('G'), LString("F-G")),
    ]),
    generations = 10,
    angle = 90.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.3",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → F+G, G → F-G",
    ),
))

# 22. Twin Dragon
register_species!(LSystemDef(
    name = "Twin Dragon",
    category = :dragon_family,
    axiom = LString("F+F+"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+G")),
        Rule(LSymbol('G'), LString("F-G")),
    ]),
    generations = 10,
    angle = 90.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Dragon variant",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → F+G, G → F-G (twin)",
    ),
))

# 23. Terdragon
register_species!(LSystemDef(
    name = "Terdragon",
    category = :dragon_family,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F"))]),
    generations = 7,
    angle = 120.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Davis & Knuth",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F",
    ),
))

# 24. Dragon Lake
register_species!(LSystemDef(
    name = "Dragon Lake",
    category = :dragon_family,
    axiom = LString("F-F-F-F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+G")),
        Rule(LSymbol('G'), LString("F-G")),
    ]),
    generations = 8,
    angle = 90.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Dragon variant",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → F+G, G → F-G (lake)",
    ),
))

# 25. Dragon of Eve
register_species!(LSystemDef(
    name = "Dragon of Eve",
    category = :dragon_family,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("+F--G+")),
        Rule(LSymbol('G'), LString("-F++G-")),
    ]),
    generations = 10,
    angle = 45.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Dragon variant",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → +F--G+, G → -F++G-",
    ),
))

# 26. Hexadragon
register_species!(LSystemDef(
    name = "Hexadragon",
    category = :dragon_family,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+G+")),
        Rule(LSymbol('G'), LString("-F-G")),
    ]),
    generations = 8,
    angle = 60.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Dragon hexagonal variant",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → F+G+, G → -F-G",
    ),
))

# 27. Fibonacci Dragon
register_species!(LSystemDef(
    name = "Fibonacci Dragon",
    category = :dragon_family,
    axiom = LString("G"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("G+F+G")),
        Rule(LSymbol('G'), LString("F-G-F")),
    ]),
    generations = 8,
    angle = 60.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fibonacci-Dragon variant",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → G+F+G, G → F-G-F",
    ),
))

# 28. Cross Dragon
register_species!(LSystemDef(
    name = "Cross Dragon",
    category = :dragon_family,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+G")),
        Rule(LSymbol('G'), LString("F-G")),
    ]),
    generations = 8,
    angle = 90.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Dragon variant",
        :linecolor => "#ff5555",
        :linewidth => 0.5,
        :rule_notation => "F → F+G, G → F-G (cross)",
    ),
))
