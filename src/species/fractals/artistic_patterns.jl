# Artistic Patterns — 17 artistic and decorative L-systems
# Reference: Various fractal patterns

# 84. Cross
register_species!(LSystemDef(
    name = "Cross",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F+F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Cross pattern",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F+F+F",
    ),
))

# 85. Crystal
register_species!(LSystemDef(
    name = "Crystal",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+F++F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Crystal growth",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → FF+F++F+F",
    ),
))

# 86. Rings
register_species!(LSystemDef(
    name = "Rings",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F+F+FF"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Ring pattern",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → FF+F+F+F+FF",
    ),
))

# 87. Pentadendrite
register_species!(LSystemDef(
    name = "Pentadendrite",
    category = :artistic_patterns,
    axiom = LString("F-F-F-F-F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F-F++F+F-F"))]),
    generations = 3,
    angle = 72.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Pentadendrite fractal",
        :linecolor => "#ffb86c",
        :linewidth => 0.5,
        :rule_notation => "F → F-F-F++F+F-F",
    ),
))

# 88. Pentigree
register_species!(LSystemDef(
    name = "Pentigree",
    category = :artistic_patterns,
    axiom = LString("F-F-F-F-F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F++F+F-F-F"))]),
    generations = 3,
    angle = 72.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Pentigree pattern",
        :linecolor => "#ffb86c",
        :linewidth => 0.5,
        :rule_notation => "F → F-F++F+F-F-F",
    ),
))

# 89. Pentagon
register_species!(LSystemDef(
    name = "Pentagon",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F+F-F-F+F"))]),
    generations = 3,
    angle = 72.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Pentagon fractal",
        :linecolor => "#ffb86c",
        :linewidth => 0.5,
        :rule_notation => "F → F+F+F-F-F+F",
    ),
))

# 90. Hexagonal Web
register_species!(LSystemDef(
    name = "Hexagonal Web",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+FF++F+F"))]),
    generations = 3,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Hexagonal pattern",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F+FF++F+F (60°)",
    ),
))

# 91. Starburst
register_species!(LSystemDef(
    name = "Starburst",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+F++F+F+FF"))]),
    generations = 3,
    angle = 72.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Starburst pattern",
        :linecolor => "#ffb86c",
        :linewidth => 0.5,
        :rule_notation => "F → FF+F++F+F+FF (72°)",
    ),
))

# 92. Diamond
register_species!(LSystemDef(
    name = "Diamond",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-FF+F+F-F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Diamond pattern",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-FF+F+F-F",
    ),
))

# 93. Snowflake Sweep
register_species!(LSystemDef(
    name = "Snowflake Sweep",
    category = :artistic_patterns,
    axiom = LString("F++F++F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F--F+F"))]),
    generations = 4,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Snowflake variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F--F+F (sweep)",
    ),
))

# 94. Quadrilateral
register_species!(LSystemDef(
    name = "Quadrilateral",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-FF+FF+F+F-F-FF+F+F-F-FF-FF+F"))]),
    generations = 2,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Quadrilateral fractal",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F-FF+FF+F+F-F-FF+F+F-F-FF-FF+F",
    ),
))

# 95. Doily
register_species!(LSystemDef(
    name = "Doily",
    category = :artistic_patterns,
    axiom = LString("F--F--F--F--F--F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F--F+F"))]),
    generations = 3,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Doily pattern",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F+F--F+F (doily)",
    ),
))

# 96. Tiling 1
register_species!(LSystemDef(
    name = "Tiling 1",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Tiling pattern",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F (tiling)",
    ),
))

# 97. Wheel
register_species!(LSystemDef(
    name = "Wheel",
    category = :artistic_patterns,
    axiom = LString("F+F+F+F+F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 3,
    angle = 45.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Wheel pattern",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F (45°)",
    ),
))

# 98. Spiral Tiling
register_species!(LSystemDef(
    name = "Spiral Tiling",
    category = :artistic_patterns,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F+FF"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Spiral tiling",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F+FF",
    ),
))

# 99. Triangular Grid
register_species!(LSystemDef(
    name = "Triangular Grid",
    category = :artistic_patterns,
    axiom = LString("F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 4,
    angle = 120.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Triangular grid",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F (120°)",
    ),
))

# 100. Leaf Skeleton
register_species!(LSystemDef(
    name = "Leaf Skeleton",
    category = :artistic_patterns,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 45.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Leaf skeleton pattern",
        :linecolor => "#bd93f9",
        :linewidth => 0.5,
        :rule_notation => "X → F[+X][-X]FX, F → FF (45°)",
    ),
))
