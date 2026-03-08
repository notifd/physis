# Space-Filling Curves — 12 space-filling curve L-systems
# Reference: ABOP §1.3

# 37. Hilbert Curve
register_species!(LSystemDef(
    name = "Hilbert Curve",
    category = :space_filling,
    axiom = LString("L"),
    rules = RuleSet([
        Rule(LSymbol('L'), LString("+RF-LFL-FR+")),
        Rule(LSymbol('R'), LString("-LF+RFR+FL-")),
    ]),
    generations = 5,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.3",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "L → +RF-LFL-FR+, R → -LF+RFR+FL-",
    ),
))

# 38. Moore Curve
register_species!(LSystemDef(
    name = "Moore Curve",
    category = :space_filling,
    axiom = LString("LFL+F+LFL"),
    rules = RuleSet([
        Rule(LSymbol('L'), LString("-RF+LFL+FR-")),
        Rule(LSymbol('R'), LString("+LF-RFR-FL+")),
    ]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Moore 1900",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "L → -RF+LFL+FR-, R → +LF-RFR-FL+",
    ),
))

# 39. Peano Curve
register_species!(LSystemDef(
    name = "Peano Curve",
    category = :space_filling,
    axiom = LString("L"),
    rules = RuleSet([
        Rule(LSymbol('L'), LString("LFRFL-F-RFLFR+F+LFRFL")),
        Rule(LSymbol('R'), LString("RFLFR+F+LFRFL-F-RFLFR")),
    ]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Peano 1890",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "L → LFRFL-F-RFLFR+F+LFRFL",
    ),
))

# 40. Gosper Curve (Flowsnake)
register_species!(LSystemDef(
    name = "Gosper Curve",
    category = :space_filling,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+G++G-F--FF-G+")),
        Rule(LSymbol('G'), LString("-F+GG++G+F--F-G")),
    ]),
    generations = 4,
    angle = 60.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Gosper flowsnake",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → F+G++G-F--FF-G+, G → -F+GG++G+F--F-G",
    ),
))

# 41. Quadratic Gosper
register_species!(LSystemDef(
    name = "Quadratic Gosper",
    category = :space_filling,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("FF-F-F-F-F-F+F+F+F+F+FF")),
    ]),
    generations = 2,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Quadratic Gosper",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → FF-F-F-F-F-F+F+F+F+F+FF",
    ),
))

# 42. Hilbert II
register_species!(LSystemDef(
    name = "Hilbert II",
    category = :space_filling,
    axiom = LString("L"),
    rules = RuleSet([
        Rule(LSymbol('L'), LString("+RF-LFL-FR+")),
        Rule(LSymbol('R'), LString("-LF+RFR+FL-")),
    ]),
    generations = 6,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Hilbert curve level 6",
        :linecolor => "#f1fa8c",
        :linewidth => 0.3,
        :rule_notation => "L → +RF-LFL-FR+, R → -LF+RFR+FL- (n=6)",
    ),
))

# 43. Serpentine Curve
register_species!(LSystemDef(
    name = "Serpentine Curve",
    category = :space_filling,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Space-filling variant",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F (4-seed)",
    ),
))

# 44. Dekking Curve
register_species!(LSystemDef(
    name = "Dekking Curve",
    category = :space_filling,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+F+F-F-F")),
    ]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Dekking 1982",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → F+F+F-F-F",
    ),
))

# 45. Wunderlich 1
register_species!(LSystemDef(
    name = "Wunderlich 1",
    category = :space_filling,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("-F+F-F+F+F-F-F+F-F+F+F-F+F-F-F+F-"))]),
    generations = 2,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Wunderlich 1973",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → -F+F-F+F+F-F-F+F-F+F+F-F+F-F-F+F-",
    ),
))

# 46. Z-Order Curve
register_species!(LSystemDef(
    name = "Z-Order Curve",
    category = :space_filling,
    axiom = LString("L"),
    rules = RuleSet([
        Rule(LSymbol('L'), LString("LF+RFR+FL")),
        Rule(LSymbol('R'), LString("-LF-RFR-FL-")),
    ]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Z-order space filling",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "L → LF+RFR+FL, R → -LF-RFR-FL-",
    ),
))

# 47. Cross-Stitch Curve
register_species!(LSystemDef(
    name = "Cross-Stitch Curve",
    category = :space_filling,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F+F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Space-filling variant",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F+F+F (cross)",
    ),
))

# 48. Peano-Gosper Hybrid
register_species!(LSystemDef(
    name = "Peano-Gosper Hybrid",
    category = :space_filling,
    axiom = LString("F"),
    rules = RuleSet([
        Rule(LSymbol('F'), LString("F+G++G-F--FF-G+")),
        Rule(LSymbol('G'), LString("-F+GG++G+F--F-G")),
    ]),
    generations = 3,
    angle = 60.0,
    draw_chars = Set(['F', 'G']),
    metadata = Dict{Symbol, Any}(
        :reference => "Peano-Gosper variant",
        :linecolor => "#f1fa8c",
        :linewidth => 0.5,
        :rule_notation => "F → F+G++G-F--FF-G+ (n=3)",
    ),
))
