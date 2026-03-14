# Plants & Trees — Documented L-system plant models from the literature
#
# 2D plants: ABOP §1.5 Fig 1.24a-f, Paul Bourke's collection
# 3D plants: Houdini/ABOP ternary tree, Cornell CS490, L3D repository
#
# Every entry below has a literature citation. No made-up species.

# ── 2D Plants (ABOP Fig 1.24) ───────────────────────────────────

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
        :reference => "ABOP Fig 1.24a, p.25",
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
        :reference => "ABOP Fig 1.24c, p.25",
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
    generations = 7,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24d, p.25",
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
    generations = 7,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP Fig 1.24e, p.25",
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
        :reference => "ABOP Fig 1.24f, p.25",
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
        :reference => "ABOP Fig 1.24b, p.25",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[+F]F[-F][F]",
    ),
))

# ── 2D Plants (Paul Bourke collection) ──────────────────────────

# 55. Bush 1 (Bourke)
register_species!(LSystemDef(
    name = "Bush 1 (Bourke)",
    category = :plants_trees,
    axiom = LString("Y"),
    rules = RuleSet([
        Rule(LSymbol('X'), LString("X[-FFF][+FFF]FX")),
        Rule(LSymbol('Y'), LString("YFX[+Y][-Y]")),
    ]),
    generations = 6,
    angle = 25.7,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Paul Bourke, paulbourke.net/fractals/lsys/",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "X → X[-FFF][+FFF]FX, Y → YFX[+Y][-Y]",
    ),
))

# 56. Bush 3 (Bourke)
register_species!(LSystemDef(
    name = "Bush 3 (Bourke)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F[+FF][-FF]F[-F][+F]F"))]),
    generations = 3,
    angle = 35.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Paul Bourke, paulbourke.net/fractals/lsys/",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[+FF][-FF]F[-F][+F]F",
    ),
))

# 57. Weed (Bourke)
register_species!(LSystemDef(
    name = "Weed (Bourke)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("FF-[XY]+[XY]")),
        Rule(LSymbol('X'), LString("+FY")),
        Rule(LSymbol('Y'), LString("-FX")),
    ]),
    generations = 6,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Paul Bourke, paulbourke.net/fractals/lsys/",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "F → FF-[XY]+[XY], X → +FY, Y → -FX",
    ),
))

# 58. Saupe Bush (Bourke/Saupe)
register_species!(LSystemDef(
    name = "Saupe Bush (Bourke)",
    category = :plants_trees,
    axiom = LString("VZFFF"),
    rules = RuleSet([
        Rule(LSymbol('V'), LString("[+++W][---W]YV")),
        Rule(LSymbol('W'), LString("+X[-W]Z")),
        Rule(LSymbol('X'), LString("-W[+X]Z")),
        Rule(LSymbol('Y'), LString("YZ")),
        Rule(LSymbol('Z'), LString("[-FFF][+FFF]F")),
    ]),
    generations = 7,
    angle = 20.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "D. Saupe, via Paul Bourke, paulbourke.net/fractals/lsys/",
        :linecolor => "#50fa7b",
        :linewidth => 0.6,
        :rule_notation => "V → [+++W][---W]YV, W → +X[-W]Z, X → -W[+X]Z, Y → YZ, Z → [-FFF][+FFF]F",
    ),
))

# ── 3D Plants (literature) ──────────────────────────────────────

# 59. 3D Ternary Tree (Houdini/ABOP)
# The canonical non-parametric 3D L-system tree. Three branches pitched
# down and separated by 90° roll at each node.
# Note: Houdini source prefixes the rule with `"` (scale-down operator)
# which we don't support; branches are uniform length without it.
register_species!(LSystemDef(
    name = "3D Ternary Tree (Houdini)",
    category = :plants_trees,
    axiom = LString("FFFA"),
    rules = RuleSet([
        Rule(LSymbol('A'), LString("[&FFFA]////[&FFFA]////[&FFFA]")),
    ]),
    generations = 4,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Houdini L-System documentation, SideFX; derived from ABOP",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "A → [&FFFA]////[&FFFA]////[&FFFA]",
        :is_3d => true,
        :glb_color => (0.35, 0.25, 0.15),
    ),
))

# 60. Cornell 3D Tree 1
# 3D tree with pitch, roll, and yaw branching. Uses turn-around (||)
# for symmetric branch pairs.
register_species!(LSystemDef(
    name = "Cornell 3D Tree 1",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F[-&\\F][\\++&F]||F[--&/F][+&F]")),
    ]),
    generations = 3,
    angle = 22.5,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Chen, Cornell CS490 Project, 1994-95, 3D-1",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[-&\\F][\\++&F]||F[--&/F][+&F]",
        :is_3d => true,
        :glb_color => (0.18, 0.55, 0.22),
    ),
))

# 61. Cornell 3D Tree 2
# Compact 3D tree with pitch-yaw branches and roll separation.
register_species!(LSystemDef(
    name = "Cornell 3D Tree 2",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F[&+F]F[-/F][-/F][&F]")),
    ]),
    generations = 3,
    angle = 28.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Chen, Cornell CS490 Project, 1994-95, 3D-2",
        :linecolor => "#50fa7b",
        :linewidth => 1.0,
        :rule_notation => "F → F[&+F]F[-/F][-/F][&F]",
        :is_3d => true,
        :glb_color => (0.18, 0.55, 0.22),
    ),
))

# 62. L3D Simple 3D Bush
# Curved 3D bush using pitch, roll, yaw, and turn-around.
register_species!(LSystemDef(
    name = "3D Bush (L3D)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F[-&\\F][\\++&F]|F[-&/F][+&F]")),
    ]),
    generations = 3,
    angle = 12.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "abiusx/L3D, simple.l3d",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "F → F[-&\\F][\\++&F]|F[-&/F][+&F]",
        :is_3d => true,
        :glb_color => (0.15, 0.45, 0.18),
    ),
))

# 63. L3D 3D Bird's Nest
# Complex two-rule 3D structure with interleaved branching.
register_species!(LSystemDef(
    name = "3D Bird's Nest (L3D)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("[-&/G][/++&G]||F[--&\\G][+&G]FF-[-F+F+F]-[^/F-F-F&\\]")),
        Rule(LSymbol('G'), LString("F[+G][-G]F[+G][-G]FG")),
    ]),
    generations = 3,
    angle = 15.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "abiusx/L3D, birds-nest.l3d",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "F → [-&/G][/++&G]||F[--&\\G][+&G]FF-[-F+F+F]-[^/F-F-F&\\], G → F[+G][-G]F[+G][-G]FG",
        :is_3d => true,
        :glb_color => (0.35, 0.25, 0.15),
    ),
))

# 64. L3D 3D Tangle
# Single-rule 3D structure with opposing pitch branches.
register_species!(LSystemDef(
    name = "3D Tangle (L3D)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("FF-[&F^F^F]+[^F&F&F]+[^f^f&f]")),
    ]),
    generations = 4,
    angle = 22.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "abiusx/L3D, birds-nest2.l3d",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "F → FF-[&F^F^F]+[^F&F&F]+[^f^f&f]",
        :is_3d => true,
        :glb_color => (0.20, 0.50, 0.25),
    ),
))

# 65. L3D 3D Seaweed
# 3D seaweed with opposing pitch branches and roll separation.
register_species!(LSystemDef(
    name = "3D Seaweed (L3D)",
    category = :plants_trees,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("FF-[&F^F^F]+[^F&F&F]/[^f^f&f]")),
    ]),
    generations = 4,
    angle = 22.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "abiusx/L3D, seaweed.l3d",
        :linecolor => "#50fa7b",
        :linewidth => 0.8,
        :rule_notation => "F → FF-[&F^F^F]+[^F&F&F]/[^f^f&f]",
        :is_3d => true,
        :glb_color => (0.10, 0.40, 0.30),
    ),
))
