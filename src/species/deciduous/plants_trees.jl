# Plants & Trees — 35 plant and tree L-systems
# Reference: ABOP §1.5, Fig 1.24

# 49. Plant 1 (ABOP 1.24a)
register_species!(LSystemDef(
    name = "Plant 1 (ABOP 1.24a)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))]),
    generations = 5,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24a",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[+F]F[-F]F",
    ),
))

# 50. Plant 2 (ABOP 1.24c)
register_species!(LSystemDef(
    name = "Plant 2 (ABOP 1.24c)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF-[-F+F+F]+[+F-F-F]"))]),
    generations = 4,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24c",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → FF-[-F+F+F]+[+F-F-F]",
    ),
))

# 51. Plant 3 (ABOP 1.24d)
register_species!(LSystemDef(
    name = "Plant 3 (ABOP 1.24d)",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24d",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X]F[-X]+X, F → FF",
    ),
))

# 52. Plant 4 (ABOP 1.24e)
register_species!(LSystemDef(
    name = "Plant 4 (ABOP 1.24e)",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24e",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X][-X]FX, F → FF",
    ),
))

# 53. Plant 5 (ABOP 1.24f)
register_species!(LSystemDef(
    name = "Plant 5 (ABOP 1.24f)",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F-[[X]+X]+F[+FX]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24f",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "X → F-[[X]+X]+F[+FX]-X, F → FF",
    ),
))

# 54. Plant 6 (ABOP 1.24b)
register_species!(LSystemDef(
    name = "Plant 6 (ABOP 1.24b)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F][F]"))]),
    generations = 5,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24b",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[+F]F[-F][F]",
    ),
))

# 55. Willow
register_species!(LSystemDef(
    name = "Willow",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X][+X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 15.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Plant variant",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[-X][+X]FX, F → FF",
    ),
))

# 56. Fern
register_species!(LSystemDef(
    name = "Fern",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F+[[X]-X]-F[-FX]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fern-like plant",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "X → F+[[X]-X]-F[-FX]+X, F → FF",
    ),
))

# 57. Bamboo
register_species!(LSystemDef(
    name = "Bamboo",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF[+F][-F]"))]),
    generations = 5,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bamboo-like plant",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → FF[+F][-F]",
    ),
))

# 58. Seaweed
register_species!(LSystemDef(
    name = "Seaweed",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+[+F-F-F]-[-F+F+F]"))]),
    generations = 4,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Seaweed pattern",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "F → FF+[+F-F-F]-[-F+F+F]",
    ),
))

# 59. Bushy Tree
register_species!(LSystemDef(
    name = "Bushy Tree",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+[+F-F-F]-[-F+F+F]"))]),
    generations = 4,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bushy tree variant",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → FF+[+F-F-F]-[-F+F+F] (25.7°)",
    ),
))

# 60. Thistle
register_species!(LSystemDef(
    name = "Thistle",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))]),
    generations = 4,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Thistle-like plant",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[+F]F[-F]F (30°)",
    ),
))

# 61. Cedar
register_species!(LSystemDef(
    name = "Cedar",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Cedar-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "X → F[+X][-X]FX, F → FF (30°)",
    ),
))

# 62. Elm
register_species!(LSystemDef(
    name = "Elm",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Elm-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "X → F[+X]F[-X]+X, F → FF (25°)",
    ),
))

# 63. Spruce
register_species!(LSystemDef(
    name = "Spruce",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X][+X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 35.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Spruce-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "X → F[-X][+X]FX, F → FF (35°)",
    ),
))

# 64. Mangrove
register_species!(LSystemDef(
    name = "Mangrove",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]F[-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Mangrove-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X][-X]F[-X]FX, F → FF",
    ),
))

# 65. Palm Frond
register_species!(LSystemDef(
    name = "Palm Frond",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F][-F]F[+F]"))]),
    generations = 4,
    angle = 35.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Palm frond pattern",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[+F][-F]F[+F]",
    ),
))

# 66. Bush
register_species!(LSystemDef(
    name = "Bush",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF[+F][-F]F[-F][+F]"))]),
    generations = 4,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bush pattern",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "F → FF[+F][-F]F[-F][+F]",
    ),
))

# 67. Birch
register_species!(LSystemDef(
    name = "Birch",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]+F[+X]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Birch-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[-X]+F[+X]-X, F → FF",
    ),
))

# 68. Acacia
register_species!(LSystemDef(
    name = "Acacia",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("FF[+X][-X]F[+X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Acacia-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → FF[+X][-X]F[+X]FX, F → FF",
    ),
))

# 69. Heather
register_species!(LSystemDef(
    name = "Heather",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]"))]),
    generations = 5,
    angle = 18.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Heather-like shrub",
        :linecolor => "#50fa7b",
        :linewidth => 0.6,
        :rule_notation => "F → F[+F]F[-F] (18°)",
    ),
))

# 70. Kelp
register_species!(LSystemDef(
    name = "Kelp",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F+[[X]-X]-F[-FX]+X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Kelp-like pattern",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F+[[X]-X]-F[-FX]+X, F → FF (20°)",
    ),
))

# 71. Ivy
register_species!(LSystemDef(
    name = "Ivy",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X]F[+X]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 28.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Ivy-like vine",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[-X]F[+X]-X, F → FF",
    ),
))

# 72. Moss
register_species!(LSystemDef(
    name = "Moss",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F][-F]F[+F][-F]F"))]),
    generations = 3,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Moss-like growth",
        :linecolor => "#50fa7b",
        :linewidth => 0.6,
        :rule_notation => "F → F[+F][-F]F[+F][-F]F",
    ),
))

# 73. Pine
register_species!(LSystemDef(
    name = "Pine",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[-X][+X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 6,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Pine-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[-X][+X]FX, F → FF (25°)",
    ),
))

# 74. Reed
register_species!(LSystemDef(
    name = "Reed",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF[+F][-F]"))]),
    generations = 5,
    angle = 15.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Reed-like plant",
        :linecolor => "#50fa7b",
        :linewidth => 0.6,
        :rule_notation => "F → FF[+F][-F] (15°)",
    ),
))

# 75. Lilac
register_species!(LSystemDef(
    name = "Lilac",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 28.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Lilac-like shrub",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X]F[-X]FX, F → FF (28°)",
    ),
))

# 76. Lavender
register_species!(LSystemDef(
    name = "Lavender",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F][+F][-F]F"))]),
    generations = 3,
    angle = 18.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Lavender-like plant",
        :linecolor => "#50fa7b",
        :linewidth => 0.6,
        :rule_notation => "F → F[+F]F[-F][+F][-F]F",
    ),
))

# 77. Sage
register_species!(LSystemDef(
    name = "Sage",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]F[+X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 30.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Sage-like shrub",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X][-X]F[+X]X, F → FF",
    ),
))

# 78. Bracken
register_species!(LSystemDef(
    name = "Bracken",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F-[[X]+X]+F[+FX]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Bracken fern",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "X → F-[[X]+X]+F[+FX]-X, F → FF (25°)",
    ),
))

# 79. Cypress
register_species!(LSystemDef(
    name = "Cypress",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]FX")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 12.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Cypress-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X][-X]FX, F → FF (12°)",
    ),
))

# 80. Hawthorn
register_species!(LSystemDef(
    name = "Hawthorn",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X]F[-X]-F[+X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 4,
    angle = 25.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Hawthorn-like tree",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F[+X]F[-X]-F[+X]X, F → FF",
    ),
))

# 81. Vine
register_species!(LSystemDef(
    name = "Vine",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F[+X][-X]F[-X]X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 18.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Vine-like plant",
        :linecolor => "#50fa7b",
        :linewidth => 0.6,
        :rule_notation => "X → F[+X][-X]F[-X]X, F → FF (18°)",
    ),
))

# 82. Rosemary
register_species!(LSystemDef(
    name = "Rosemary",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+F][-F]F[+F]F"))]),
    generations = 4,
    angle = 22.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Rosemary-like shrub",
        :linecolor => "#50fa7b",
        :linewidth => 0.6,
        :rule_notation => "F → F[+F][-F]F[+F]F",
    ),
))

# 83. Wisteria
register_species!(LSystemDef(
    name = "Wisteria",
    category = :plants_trees,
    axiom = LString("X"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("F-[[-X]+X]+F[+FX]-X")),
        Rule(LSymbol('F'), LString("FF")),
    ]),
    generations = 5,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Wisteria-like vine",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → F-[[-X]+X]+F[+FX]-X, F → FF",
    ),
))
