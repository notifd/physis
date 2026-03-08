# Fractal Curves — 20 classic fractal curve L-systems
# Reference: ABOP §1.3, §1.7

# 1. Koch Curve
register_species!(LSystemDef(
    name = "Koch Curve",
    category = :fractal_curves,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.3",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F",
    ),
))

# 2. Koch Snowflake
register_species!(LSystemDef(
    name = "Koch Snowflake",
    category = :fractal_curves,
    axiom = LString("F--F--F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F--F+F"))]),
    generations = 4,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.3",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F--F+F",
    ),
))

# 3. Koch Anti-Snowflake
register_species!(LSystemDef(
    name = "Koch Anti-Snowflake",
    category = :fractal_curves,
    axiom = LString("F++F++F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F++F-F"))]),
    generations = 4,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Koch variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F-F++F-F",
    ),
))

# 4. Quadratic Koch Island
register_species!(LSystemDef(
    name = "Quadratic Koch Island",
    category = :fractal_curves,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-FF+F+F-F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.7",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-FF+F+F-F",
    ),
))

# 5. Koch Island 2
register_species!(LSystemDef(
    name = "Koch Island 2",
    category = :fractal_curves,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F+FFF-F-F+F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Koch variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F-F+F+FFF-F-F+F",
    ),
))

# 6. Minkowski Sausage
register_species!(LSystemDef(
    name = "Minkowski Sausage",
    category = :fractal_curves,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-FF+F+F-F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Minkowski fractal",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-FF+F+F-F",
    ),
))

# 7. Levy C Curve
register_species!(LSystemDef(
    name = "Levy C Curve",
    category = :fractal_curves,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("+F--F+"))]),
    generations = 10,
    angle = 45.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Levy 1938",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → +F--F+",
    ),
))

# 8. Cesaro Fractal
register_species!(LSystemDef(
    name = "Cesaro Fractal",
    category = :fractal_curves,
    axiom = LString("F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F"))]),
    generations = 6,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Cesaro sweep",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F",
    ),
))

# 9. Quadratic Snowflake
register_species!(LSystemDef(
    name = "Quadratic Snowflake",
    category = :fractal_curves,
    axiom = LString("FF+FF+FF+FF"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Quadratic Koch variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F",
    ),
))

# 10. Koch Curve 60
register_species!(LSystemDef(
    name = "Koch Curve 60",
    category = :fractal_curves,
    axiom = LString("F++F++F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F++F-F"))]),
    generations = 4,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Koch 60° variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F-F++F-F",
    ),
))

# 11. Triflake
register_species!(LSystemDef(
    name = "Triflake",
    category = :fractal_curves,
    axiom = LString("F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F"))]),
    generations = 6,
    angle = 120.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fractal variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F-F+F",
    ),
))

# 12. Square Curve
register_species!(LSystemDef(
    name = "Square Curve",
    category = :fractal_curves,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F+F+FF"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fractal square",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → FF+F+F+F+FF",
    ),
))

# 13. Box Fractal
register_species!(LSystemDef(
    name = "Box Fractal",
    category = :fractal_curves,
    axiom = LString("F-F-F-F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F+F-F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Vicsek fractal",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F-F+F+F-F",
    ),
))

# 14. 32-Segment Curve
register_species!(LSystemDef(
    name = "32-Segment Curve",
    category = :fractal_curves,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("-F+F-F-F+F+FF-F+F+FF+F-F-FF+FF-FF+F+F-FF-F-F+FF-F-F+F+F-F+"))]),
    generations = 2,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.7",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → -F+F-F-F+F+FF-F+F+FF+F-F-FF+FF-FF+F+F-FF-F-F+FF-F-F+F+F-F+",
    ),
))

# 15. Islands and Lakes
register_species!(LSystemDef(
    name = "Islands and Lakes",
    category = :fractal_curves,
    axiom = LString("F-F-F-F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F+FF-F-F+F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "ABOP §1.7",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F-F+F+FF-F-F+F",
    ),
))

# 16. Hexagonal Koch
register_species!(LSystemDef(
    name = "Hexagonal Koch",
    category = :fractal_curves,
    axiom = LString("F+F+F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 3,
    angle = 60.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Koch hexagonal variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F",
    ),
))

# 17. Anklet of Krishna
register_species!(LSystemDef(
    name = "Anklet of Krishna",
    category = :fractal_curves,
    axiom = LString("-F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fractal variant",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F",
    ),
))

# 18. Joined Cross Curve
register_species!(LSystemDef(
    name = "Joined Cross Curve",
    category = :fractal_curves,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+FF++F+F"))]),
    generations = 4,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fractal curve",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+FF++F+F",
    ),
))

# 19. Lace
register_species!(LSystemDef(
    name = "Lace",
    category = :fractal_curves,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F+F"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fractal lace pattern",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → F+F-F-F+F+F",
    ),
))

# 20. Maze
register_species!(LSystemDef(
    name = "Maze",
    category = :fractal_curves,
    axiom = LString("F+F+F+F"),
    rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F-F-F+F+FF"))]),
    generations = 3,
    angle = 90.0,
    draw_chars = Set(['F']),
    metadata = Dict{Symbol, Any}(
        :reference => "Fractal maze pattern",
        :linecolor => "#8be9fd",
        :linewidth => 0.5,
        :rule_notation => "F → FF+F+F-F-F+F+FF",
    ),
))
