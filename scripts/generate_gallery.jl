"""
    generate_gallery.jl — Generate an HTML gallery of 100 classic L-systems

Defines 100 L-systems across 6 categories, renders them as SVGs,
and generates a self-contained HTML gallery page with category navigation.

Usage:
    julia --project=. scripts/generate_gallery.jl [outdir]

Default output directory: gallery/

Reference: ABOP §1.3, §1.5, Fig 1.24
"""

using Physis
using CairoMakie

# ── Gallery entry type ───────────────────────────────────────────

const GalleryEntry = @NamedTuple begin
    name::String
    category::String
    axiom::LString
    rules::RuleSet
    generations::Int
    angle::Float64
    draw_chars::Set{Char}
    linecolor::String
    linewidth::Float64
    reference::String
    rule_notation::String
end

# ── Helper: substitute drawing symbols ───────────────────────────

"""
    substitute_draw_symbols(ls::LString, draw_chars::Set{Char}) -> LString

Replace non-F drawing symbols with F for turtle interpretation.
Symbols in `draw_chars` that aren't 'F' are replaced with `LSymbol('F')`.
Returns the original LString unchanged when only F is a draw char.
"""
function substitute_draw_symbols(ls::LString, draw_chars::Set{Char})
    draw_chars == Set(['F']) && return ls
    symbols = AbstractSymbol[]
    sizehint!(symbols, length(ls))
    for s in ls
        c = name(s)
        if c != 'F' && c in draw_chars
            push!(symbols, LSymbol('F'))
        else
            push!(symbols, s)
        end
    end
    LString(symbols)
end

# ── Slug helper ──────────────────────────────────────────────────

"""
    entry_slug(entry_name::String) -> String

Convert an entry name to a URL/filename-safe slug.
"""
function entry_slug(entry_name::String)
    s = replace(lowercase(entry_name), r"[^a-z0-9]+" => "-")
    strip(s, '-')
end

# ── Gallery entries: 100 L-systems across 6 categories ───────────

const GALLERY = GalleryEntry[
    # ═══════════════════════════════════════════════════════════════
    # FRACTAL CURVES (~20 entries)
    # ═══════════════════════════════════════════════════════════════

    # 1. Koch Curve — ABOP §1.3
    (
        name = "Koch Curve",
        category = "Fractal Curves",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "ABOP §1.3",
        rule_notation = "F → F+F-F-F+F",
    ),
    # 2. Koch Snowflake — ABOP §1.3
    (
        name = "Koch Snowflake",
        category = "Fractal Curves",
        axiom = LString("F--F--F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F--F+F"))]),
        generations = 4,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "ABOP §1.3",
        rule_notation = "F → F+F--F+F",
    ),
    # 3. Koch Anti-Snowflake
    (
        name = "Koch Anti-Snowflake",
        category = "Fractal Curves",
        axiom = LString("F++F++F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F++F-F"))]),
        generations = 4,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Koch variant",
        rule_notation = "F → F-F++F-F",
    ),
    # 4. Quadratic Koch Island
    (
        name = "Quadratic Koch Island",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-FF+F+F-F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "ABOP §1.7",
        rule_notation = "F → F+F-F-FF+F+F-F",
    ),
    # 5. Koch Island 2
    (
        name = "Koch Island 2",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F+FFF-F-F+F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Koch variant",
        rule_notation = "F → F-F+F+FFF-F-F+F",
    ),
    # 6. Minkowski Sausage
    (
        name = "Minkowski Sausage",
        category = "Fractal Curves",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-FF+F+F-F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Minkowski fractal",
        rule_notation = "F → F+F-F-FF+F+F-F",
    ),
    # 7. Levy C Curve
    (
        name = "Levy C Curve",
        category = "Fractal Curves",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("+F--F+"))]),
        generations = 10,
        angle = 45.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Levy 1938",
        rule_notation = "F → +F--F+",
    ),
    # 8. Cesaro Fractal
    (
        name = "Cesaro Fractal",
        category = "Fractal Curves",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F"))]),
        generations = 6,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Cesaro sweep",
        rule_notation = "F → F+F-F",
    ),
    # 9. Quadratic Snowflake
    (
        name = "Quadratic Snowflake",
        category = "Fractal Curves",
        axiom = LString("FF+FF+FF+FF"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Quadratic Koch variant",
        rule_notation = "F → F+F-F-F+F",
    ),
    # 10. Koch Curve 60
    (
        name = "Koch Curve 60",
        category = "Fractal Curves",
        axiom = LString("F++F++F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F++F-F"))]),
        generations = 4,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Koch 60° variant",
        rule_notation = "F → F-F++F-F",
    ),
    # 11. Triflake
    (
        name = "Triflake",
        category = "Fractal Curves",
        axiom = LString("F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F"))]),
        generations = 6,
        angle = 120.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Fractal variant",
        rule_notation = "F → F-F+F",
    ),
    # 12. Square Curve
    (
        name = "Square Curve",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F+F+FF"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Fractal square",
        rule_notation = "F → FF+F+F+F+FF",
    ),
    # 13. Box Fractal
    (
        name = "Box Fractal",
        category = "Fractal Curves",
        axiom = LString("F-F-F-F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F+F-F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Vicsek fractal",
        rule_notation = "F → F-F+F+F-F",
    ),
    # 14. 32-Segment Curve
    (
        name = "32-Segment Curve",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("-F+F-F-F+F+FF-F+F+FF+F-F-FF+FF-FF+F+F-FF-F-F+FF-F-F+F+F-F+"))]),
        generations = 2,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "ABOP §1.7",
        rule_notation = "F → -F+F-F-F+F+FF-F+F+FF+F-F-FF+FF-FF+F+F-FF-F-F+FF-F-F+F+F-F+",
    ),
    # 15. Islands and Lakes
    (
        name = "Islands and Lakes",
        category = "Fractal Curves",
        axiom = LString("F-F-F-F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F+F+FF-F-F+F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "ABOP §1.7",
        rule_notation = "F → F-F+F+FF-F-F+F",
    ),
    # 16. Hexagonal Koch
    (
        name = "Hexagonal Koch",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 3,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Koch hexagonal variant",
        rule_notation = "F → F+F-F-F+F",
    ),
    # 17. Anklet of Krishna
    (
        name = "Anklet of Krishna",
        category = "Fractal Curves",
        axiom = LString("-F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Fractal variant",
        rule_notation = "F → F+F-F-F+F",
    ),
    # 18. Joined Cross Curve
    (
        name = "Joined Cross Curve",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+FF++F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Fractal curve",
        rule_notation = "F → F+FF++F+F",
    ),
    # 19. Lace
    (
        name = "Lace",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F+F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Fractal lace pattern",
        rule_notation = "F → F+F-F-F+F+F",
    ),
    # 20. Maze
    (
        name = "Maze",
        category = "Fractal Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F-F-F+F+FF"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Fractal maze pattern",
        rule_notation = "F → FF+F+F-F-F+F+FF",
    ),

    # ═══════════════════════════════════════════════════════════════
    # DRAGON FAMILY (~8 entries)
    # ═══════════════════════════════════════════════════════════════

    # 21. Dragon Curve — ABOP §1.3
    (
        name = "Dragon Curve",
        category = "Dragon Family",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+G")),
            Rule(LSymbol('G'), LString("F-G")),
        ]),
        generations = 10,
        angle = 90.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "ABOP §1.3",
        rule_notation = "F → F+G, G → F-G",
    ),
    # 22. Twin Dragon
    (
        name = "Twin Dragon",
        category = "Dragon Family",
        axiom = LString("F+F+"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+G")),
            Rule(LSymbol('G'), LString("F-G")),
        ]),
        generations = 10,
        angle = 90.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "Dragon variant",
        rule_notation = "F → F+G, G → F-G (twin)",
    ),
    # 23. Terdragon
    (
        name = "Terdragon",
        category = "Dragon Family",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F"))]),
        generations = 7,
        angle = 120.0,
        draw_chars = Set(['F']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "Davis & Knuth",
        rule_notation = "F → F+F-F",
    ),
    # 24. Dragon Lake
    (
        name = "Dragon Lake",
        category = "Dragon Family",
        axiom = LString("F-F-F-F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+G")),
            Rule(LSymbol('G'), LString("F-G")),
        ]),
        generations = 8,
        angle = 90.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "Dragon variant",
        rule_notation = "F → F+G, G → F-G (lake)",
    ),
    # 25. Dragon of Eve
    (
        name = "Dragon of Eve",
        category = "Dragon Family",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("+F--G+")),
            Rule(LSymbol('G'), LString("-F++G-")),
        ]),
        generations = 10,
        angle = 45.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "Dragon variant",
        rule_notation = "F → +F--G+, G → -F++G-",
    ),
    # 26. Hexadragon
    (
        name = "Hexadragon",
        category = "Dragon Family",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+G+")),
            Rule(LSymbol('G'), LString("-F-G")),
        ]),
        generations = 8,
        angle = 60.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "Dragon hexagonal variant",
        rule_notation = "F → F+G+, G → -F-G",
    ),
    # 27. Fibonacci Dragon
    (
        name = "Fibonacci Dragon",
        category = "Dragon Family",
        axiom = LString("G"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("G+F+G")),
            Rule(LSymbol('G'), LString("F-G-F")),
        ]),
        generations = 8,
        angle = 60.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "Fibonacci-Dragon variant",
        rule_notation = "F → G+F+G, G → F-G-F",
    ),
    # 28. Cross Dragon
    (
        name = "Cross Dragon",
        category = "Dragon Family",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+G")),
            Rule(LSymbol('G'), LString("F-G")),
        ]),
        generations = 8,
        angle = 90.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff5555",
        linewidth = 0.5,
        reference = "Dragon variant",
        rule_notation = "F → F+G, G → F-G (cross)",
    ),

    # ═══════════════════════════════════════════════════════════════
    # SIERPINSKI FAMILY (~8 entries)
    # ═══════════════════════════════════════════════════════════════

    # 29. Sierpinski Triangle — ABOP §1.3
    (
        name = "Sierpinski Triangle",
        category = "Sierpinski Family",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("G-F-G")),
            Rule(LSymbol('G'), LString("F+G+F")),
        ]),
        generations = 6,
        angle = 60.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "ABOP §1.3",
        rule_notation = "F → G-F-G, G → F+G+F",
    ),
    # 30. Sierpinski Arrowhead
    (
        name = "Sierpinski Arrowhead",
        category = "Sierpinski Family",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("G+F+G")),
            Rule(LSymbol('G'), LString("F-G-F")),
        ]),
        generations = 7,
        angle = 60.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "Sierpinski arrowhead",
        rule_notation = "F → G+F+G, G → F-G-F",
    ),
    # 31. Sierpinski Square
    (
        name = "Sierpinski Square",
        category = "Sierpinski Family",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F+F+F+F-F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "Sierpinski square curve",
        rule_notation = "F → FF+F+F+F+F+F-F",
    ),
    # 32. Sierpinski Carpet
    (
        name = "Sierpinski Carpet",
        category = "Sierpinski Family",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F-F+F+F+F-F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "Sierpinski carpet variant",
        rule_notation = "F → F+F-F-F-F+F+F+F-F",
    ),
    # 33. Sierpinski Hexagon
    (
        name = "Sierpinski Hexagon",
        category = "Sierpinski Family",
        axiom = LString("F+F+F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 4,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "Sierpinski hexagonal variant",
        rule_notation = "F → F+F-F-F+F",
    ),
    # 34. Sierpinski Median
    (
        name = "Sierpinski Median",
        category = "Sierpinski Family",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("+G-F-G+")),
            Rule(LSymbol('G'), LString("-F+G+F-")),
        ]),
        generations = 8,
        angle = 60.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "Sierpinski median curve",
        rule_notation = "F → +G-F-G+, G → -F+G+F-",
    ),
    # 35. Sierpinski Pentagon
    (
        name = "Sierpinski Pentagon",
        category = "Sierpinski Family",
        axiom = LString("F+F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 4,
        angle = 72.0,
        draw_chars = Set(['F']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "Sierpinski pentagonal variant",
        rule_notation = "F → F+F-F-F+F (72°)",
    ),
    # 36. Sierpinski Maze
    (
        name = "Sierpinski Maze",
        category = "Sierpinski Family",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F+F"))]),
        generations = 4,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#ff79c6",
        linewidth = 0.5,
        reference = "Sierpinski labyrinth",
        rule_notation = "F → F+F-F-F+F+F",
    ),

    # ═══════════════════════════════════════════════════════════════
    # SPACE-FILLING CURVES (~12 entries)
    # ═══════════════════════════════════════════════════════════════

    # 37. Hilbert Curve — ABOP §1.3
    (
        name = "Hilbert Curve",
        category = "Space-Filling Curves",
        axiom = LString("L"),
        rules = RuleSet([
            Rule(LSymbol('L'), LString("+RF-LFL-FR+")),
            Rule(LSymbol('R'), LString("-LF+RFR+FL-")),
        ]),
        generations = 5,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "ABOP §1.3",
        rule_notation = "L → +RF-LFL-FR+, R → -LF+RFR+FL-",
    ),
    # 38. Moore Curve
    (
        name = "Moore Curve",
        category = "Space-Filling Curves",
        axiom = LString("LFL+F+LFL"),
        rules = RuleSet([
            Rule(LSymbol('L'), LString("-RF+LFL+FR-")),
            Rule(LSymbol('R'), LString("+LF-RFR-FL+")),
        ]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Moore 1900",
        rule_notation = "L → -RF+LFL+FR-, R → +LF-RFR-FL+",
    ),
    # 39. Peano Curve
    (
        name = "Peano Curve",
        category = "Space-Filling Curves",
        axiom = LString("L"),
        rules = RuleSet([
            Rule(LSymbol('L'), LString("LFRFL-F-RFLFR+F+LFRFL")),
            Rule(LSymbol('R'), LString("RFLFR+F+LFRFL-F-RFLFR")),
        ]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Peano 1890",
        rule_notation = "L → LFRFL-F-RFLFR+F+LFRFL",
    ),
    # 40. Gosper Curve (Flowsnake)
    (
        name = "Gosper Curve",
        category = "Space-Filling Curves",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+G++G-F--FF-G+")),
            Rule(LSymbol('G'), LString("-F+GG++G+F--F-G")),
        ]),
        generations = 4,
        angle = 60.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Gosper flowsnake",
        rule_notation = "F → F+G++G-F--FF-G+, G → -F+GG++G+F--F-G",
    ),
    # 41. Quadratic Gosper
    (
        name = "Quadratic Gosper",
        category = "Space-Filling Curves",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("FF-F-F-F-F-F+F+F+F+F+FF")),
        ]),
        generations = 2,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Quadratic Gosper",
        rule_notation = "F → FF-F-F-F-F-F+F+F+F+F+FF",
    ),
    # 42. Hilbert II
    (
        name = "Hilbert II",
        category = "Space-Filling Curves",
        axiom = LString("L"),
        rules = RuleSet([
            Rule(LSymbol('L'), LString("+RF-LFL-FR+")),
            Rule(LSymbol('R'), LString("-LF+RFR+FL-")),
        ]),
        generations = 6,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.3,
        reference = "Hilbert curve level 6",
        rule_notation = "L → +RF-LFL-FR+, R → -LF+RFR+FL- (n=6)",
    ),
    # 43. Serpentine Curve
    (
        name = "Serpentine Curve",
        category = "Space-Filling Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Space-filling variant",
        rule_notation = "F → F+F-F-F+F (4-seed)",
    ),
    # 44. Dekking Curve
    (
        name = "Dekking Curve",
        category = "Space-Filling Curves",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+F+F-F-F")),
        ]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Dekking 1982",
        rule_notation = "F → F+F+F-F-F",
    ),
    # 45. Wunderlich 1
    (
        name = "Wunderlich 1",
        category = "Space-Filling Curves",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("-F+F-F+F+F-F-F+F-F+F+F-F+F-F-F+F-"))]),
        generations = 2,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Wunderlich 1973",
        rule_notation = "F → -F+F-F+F+F-F-F+F-F+F+F-F+F-F-F+F-",
    ),
    # 46. Z-Order Curve
    (
        name = "Z-Order Curve",
        category = "Space-Filling Curves",
        axiom = LString("L"),
        rules = RuleSet([
            Rule(LSymbol('L'), LString("LF+RFR+FL")),
            Rule(LSymbol('R'), LString("-LF-RFR-FL-")),
        ]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Z-order space filling",
        rule_notation = "L → LF+RFR+FL, R → -LF-RFR-FL-",
    ),
    # 47. Cross-Stitch Curve
    (
        name = "Cross-Stitch Curve",
        category = "Space-Filling Curves",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F+F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Space-filling variant",
        rule_notation = "F → F+F-F+F+F (cross)",
    ),
    # 48. Peano-Gosper Hybrid
    (
        name = "Peano-Gosper Hybrid",
        category = "Space-Filling Curves",
        axiom = LString("F"),
        rules = RuleSet([
            Rule(LSymbol('F'), LString("F+G++G-F--FF-G+")),
            Rule(LSymbol('G'), LString("-F+GG++G+F--F-G")),
        ]),
        generations = 3,
        angle = 60.0,
        draw_chars = Set(['F', 'G']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Peano-Gosper variant",
        rule_notation = "F → F+G++G-F--FF-G+ (n=3)",
    ),

    # ═══════════════════════════════════════════════════════════════
    # PLANTS & TREES (~35 entries)
    # ═══════════════════════════════════════════════════════════════

    # 49. Plant 1 — ABOP Fig 1.24a
    (
        name = "Plant 1 (ABOP 1.24a)",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))]),
        generations = 5,
        angle = 25.7,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "ABOP Fig 1.24a",
        rule_notation = "F → F[+F]F[-F]F",
    ),
    # 50. Plant 2 — ABOP Fig 1.24c
    (
        name = "Plant 2 (ABOP 1.24c)",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF-[-F+F+F]+[+F-F-F]"))]),
        generations = 4,
        angle = 22.5,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "ABOP Fig 1.24c",
        rule_notation = "F → FF-[-F+F+F]+[+F-F-F]",
    ),
    # 51. Plant 3 — ABOP Fig 1.24d
    (
        name = "Plant 3 (ABOP 1.24d)",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 6,
        angle = 20.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "ABOP Fig 1.24d",
        rule_notation = "X → F[+X]F[-X]+X, F → FF",
    ),
    # 52. Plant 4 — ABOP Fig 1.24e
    (
        name = "Plant 4 (ABOP 1.24e)",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X][-X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 6,
        angle = 25.7,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "ABOP Fig 1.24e",
        rule_notation = "X → F[+X][-X]FX, F → FF",
    ),
    # 53. Plant 5 — ABOP Fig 1.24f
    (
        name = "Plant 5 (ABOP 1.24f)",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F-[[X]+X]+F[+FX]-X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 22.5,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "ABOP Fig 1.24f",
        rule_notation = "X → F-[[X]+X]+F[+FX]-X, F → FF",
    ),
    # 54. Plant 6 — ABOP Fig 1.24b
    (
        name = "Plant 6 (ABOP 1.24b)",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F][F]"))]),
        generations = 5,
        angle = 20.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "ABOP Fig 1.24b",
        rule_notation = "F → F[+F]F[-F][F]",
    ),
    # 55. Willow
    (
        name = "Willow",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[-X][+X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 6,
        angle = 15.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Plant variant",
        rule_notation = "X → F[-X][+X]FX, F → FF",
    ),
    # 56. Fern
    (
        name = "Fern",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F+[[X]-X]-F[-FX]+X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 25.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Fern-like plant",
        rule_notation = "X → F+[[X]-X]-F[-FX]+X, F → FF",
    ),
    # 57. Bamboo
    (
        name = "Bamboo",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF[+F][-F]"))]),
        generations = 5,
        angle = 30.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Bamboo-like plant",
        rule_notation = "F → FF[+F][-F]",
    ),
    # 58. Seaweed
    (
        name = "Seaweed",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+[+F-F-F]-[-F+F+F]"))]),
        generations = 4,
        angle = 22.5,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Seaweed pattern",
        rule_notation = "F → FF+[+F-F-F]-[-F+F+F]",
    ),
    # 59. Bushy Tree
    (
        name = "Bushy Tree",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+[+F-F-F]-[-F+F+F]"))]),
        generations = 4,
        angle = 25.7,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Bushy tree variant",
        rule_notation = "F → FF+[+F-F-F]-[-F+F+F] (25.7°)",
    ),
    # 60. Thistle
    (
        name = "Thistle",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]F"))]),
        generations = 4,
        angle = 30.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Thistle-like plant",
        rule_notation = "F → F[+F]F[-F]F (30°)",
    ),
    # 61. Cedar
    (
        name = "Cedar",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X][-X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 30.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Cedar-like tree",
        rule_notation = "X → F[+X][-X]FX, F → FF (30°)",
    ),
    # 62. Elm
    (
        name = "Elm",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X]F[-X]+X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 25.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Elm-like tree",
        rule_notation = "X → F[+X]F[-X]+X, F → FF (25°)",
    ),
    # 63. Spruce
    (
        name = "Spruce",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[-X][+X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 35.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Spruce-like tree",
        rule_notation = "X → F[-X][+X]FX, F → FF (35°)",
    ),
    # 64. Mangrove
    (
        name = "Mangrove",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X][-X]F[-X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 22.5,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Mangrove-like tree",
        rule_notation = "X → F[+X][-X]F[-X]FX, F → FF",
    ),
    # 65. Palm Frond
    (
        name = "Palm Frond",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F][-F]F[+F]"))]),
        generations = 4,
        angle = 35.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Palm frond pattern",
        rule_notation = "F → F[+F][-F]F[+F]",
    ),
    # 66. Bush
    (
        name = "Bush",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF[+F][-F]F[-F][+F]"))]),
        generations = 4,
        angle = 20.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Bush pattern",
        rule_notation = "F → FF[+F][-F]F[-F][+F]",
    ),
    # 67. Birch
    (
        name = "Birch",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[-X]+F[+X]-X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 22.5,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Birch-like tree",
        rule_notation = "X → F[-X]+F[+X]-X, F → FF",
    ),
    # 68. Acacia
    (
        name = "Acacia",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("FF[+X][-X]F[+X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 4,
        angle = 30.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Acacia-like tree",
        rule_notation = "X → FF[+X][-X]F[+X]FX, F → FF",
    ),
    # 69. Heather
    (
        name = "Heather",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F]"))]),
        generations = 5,
        angle = 18.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.6,
        reference = "Heather-like shrub",
        rule_notation = "F → F[+F]F[-F] (18°)",
    ),
    # 70. Kelp
    (
        name = "Kelp",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F+[[X]-X]-F[-FX]+X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 20.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Kelp-like pattern",
        rule_notation = "X → F+[[X]-X]-F[-FX]+X, F → FF (20°)",
    ),
    # 71. Ivy
    (
        name = "Ivy",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[-X]F[+X]-X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 28.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Ivy-like vine",
        rule_notation = "X → F[-X]F[+X]-X, F → FF",
    ),
    # 72. Moss
    (
        name = "Moss",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F][-F]F[+F][-F]F"))]),
        generations = 3,
        angle = 25.7,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.6,
        reference = "Moss-like growth",
        rule_notation = "F → F[+F][-F]F[+F][-F]F",
    ),
    # 73. Pine
    (
        name = "Pine",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[-X][+X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 6,
        angle = 25.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Pine-like tree",
        rule_notation = "X → F[-X][+X]FX, F → FF (25°)",
    ),
    # 74. Reed
    (
        name = "Reed",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF[+F][-F]"))]),
        generations = 5,
        angle = 15.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.6,
        reference = "Reed-like plant",
        rule_notation = "F → FF[+F][-F] (15°)",
    ),
    # 75. Lilac
    (
        name = "Lilac",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X]F[-X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 28.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Lilac-like shrub",
        rule_notation = "X → F[+X]F[-X]FX, F → FF (28°)",
    ),
    # 76. Lavender
    (
        name = "Lavender",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F]F[-F][+F][-F]F"))]),
        generations = 3,
        angle = 18.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.6,
        reference = "Lavender-like plant",
        rule_notation = "F → F[+F]F[-F][+F][-F]F",
    ),
    # 77. Sage
    (
        name = "Sage",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X][-X]F[+X]X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 4,
        angle = 30.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Sage-like shrub",
        rule_notation = "X → F[+X][-X]F[+X]X, F → FF",
    ),
    # 78. Bracken
    (
        name = "Bracken",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F-[[X]+X]+F[+FX]-X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 4,
        angle = 25.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 1.0,
        reference = "Bracken fern",
        rule_notation = "X → F-[[X]+X]+F[+FX]-X, F → FF (25°)",
    ),
    # 79. Cypress
    (
        name = "Cypress",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X][-X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 12.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Cypress-like tree",
        rule_notation = "X → F[+X][-X]FX, F → FF (12°)",
    ),
    # 80. Hawthorn
    (
        name = "Hawthorn",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X]F[-X]-F[+X]X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 4,
        angle = 25.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Hawthorn-like tree",
        rule_notation = "X → F[+X]F[-X]-F[+X]X, F → FF",
    ),
    # 81. Vine
    (
        name = "Vine",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X][-X]F[-X]X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 18.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.6,
        reference = "Vine-like plant",
        rule_notation = "X → F[+X][-X]F[-X]X, F → FF (18°)",
    ),
    # 82. Rosemary
    (
        name = "Rosemary",
        category = "Plants & Trees",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F[+F][-F]F[+F]F"))]),
        generations = 4,
        angle = 22.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.6,
        reference = "Rosemary-like shrub",
        rule_notation = "F → F[+F][-F]F[+F]F",
    ),
    # 83. Wisteria
    (
        name = "Wisteria",
        category = "Plants & Trees",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F-[[-X]+X]+F[+FX]-X")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 5,
        angle = 20.0,
        draw_chars = Set(['F']),
        linecolor = "#50fa7b",
        linewidth = 0.8,
        reference = "Wisteria-like vine",
        rule_notation = "X → F-[[-X]+X]+F[+FX]-X, F → FF",
    ),

    # ═══════════════════════════════════════════════════════════════
    # ARTISTIC PATTERNS (~17 entries)
    # ═══════════════════════════════════════════════════════════════

    # 84. Cross
    (
        name = "Cross",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F+F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Cross pattern",
        rule_notation = "F → F+F-F+F+F",
    ),
    # 85. Crystal
    (
        name = "Crystal",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+F++F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Crystal growth",
        rule_notation = "F → FF+F++F+F",
    ),
    # 86. Rings
    (
        name = "Rings",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+F+F+F+FF"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Ring pattern",
        rule_notation = "F → FF+F+F+F+FF",
    ),
    # 87. Pentadendrite
    (
        name = "Pentadendrite",
        category = "Artistic Patterns",
        axiom = LString("F-F-F-F-F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F-F++F+F-F"))]),
        generations = 3,
        angle = 72.0,
        draw_chars = Set(['F']),
        linecolor = "#ffb86c",
        linewidth = 0.5,
        reference = "Pentadendrite fractal",
        rule_notation = "F → F-F-F++F+F-F",
    ),
    # 88. Pentigree
    (
        name = "Pentigree",
        category = "Artistic Patterns",
        axiom = LString("F-F-F-F-F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-F++F+F-F-F"))]),
        generations = 3,
        angle = 72.0,
        draw_chars = Set(['F']),
        linecolor = "#ffb86c",
        linewidth = 0.5,
        reference = "Pentigree pattern",
        rule_notation = "F → F-F++F+F-F-F",
    ),
    # 89. Pentagon
    (
        name = "Pentagon",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F+F-F-F+F"))]),
        generations = 3,
        angle = 72.0,
        draw_chars = Set(['F']),
        linecolor = "#ffb86c",
        linewidth = 0.5,
        reference = "Pentagon fractal",
        rule_notation = "F → F+F+F-F-F+F",
    ),
    # 90. Hexagonal Web
    (
        name = "Hexagonal Web",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+FF++F+F"))]),
        generations = 3,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Hexagonal pattern",
        rule_notation = "F → F+FF++F+F (60°)",
    ),
    # 91. Starburst
    (
        name = "Starburst",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("FF+F++F+F+FF"))]),
        generations = 3,
        angle = 72.0,
        draw_chars = Set(['F']),
        linecolor = "#ffb86c",
        linewidth = 0.5,
        reference = "Starburst pattern",
        rule_notation = "F → FF+F++F+F+FF (72°)",
    ),
    # 92. Diamond
    (
        name = "Diamond",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-FF+F+F-F"))]),
        generations = 3,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Diamond pattern",
        rule_notation = "F → F+F-F-FF+F+F-F",
    ),
    # 93. Snowflake Sweep
    (
        name = "Snowflake Sweep",
        category = "Artistic Patterns",
        axiom = LString("F++F++F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F--F+F"))]),
        generations = 4,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#8be9fd",
        linewidth = 0.5,
        reference = "Snowflake variant",
        rule_notation = "F → F+F--F+F (sweep)",
    ),
    # 94. Quadrilateral
    (
        name = "Quadrilateral",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F-FF+FF+F+F-F-FF+F+F-F-FF-FF+F"))]),
        generations = 2,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Quadrilateral fractal",
        rule_notation = "F → F-FF+FF+F+F-F-FF+F+F-F-FF-FF+F",
    ),
    # 95. Doily
    (
        name = "Doily",
        category = "Artistic Patterns",
        axiom = LString("F--F--F--F--F--F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F--F+F"))]),
        generations = 3,
        angle = 60.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Doily pattern",
        rule_notation = "F → F+F--F+F (doily)",
    ),
    # 96. Tiling 1
    (
        name = "Tiling 1",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#f1fa8c",
        linewidth = 0.5,
        reference = "Tiling pattern",
        rule_notation = "F → F+F-F-F+F (tiling)",
    ),
    # 97. Wheel
    (
        name = "Wheel",
        category = "Artistic Patterns",
        axiom = LString("F+F+F+F+F+F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 3,
        angle = 45.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Wheel pattern",
        rule_notation = "F → F+F-F-F+F (45°)",
    ),
    # 98. Spiral Tiling
    (
        name = "Spiral Tiling",
        category = "Artistic Patterns",
        axiom = LString("F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F+FF"))]),
        generations = 4,
        angle = 90.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Spiral tiling",
        rule_notation = "F → F+F-F-F+F+FF",
    ),
    # 99. Triangular Grid
    (
        name = "Triangular Grid",
        category = "Artistic Patterns",
        axiom = LString("F+F+F"),
        rules = RuleSet([Rule(LSymbol('F'), LString("F+F-F-F+F"))]),
        generations = 4,
        angle = 120.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Triangular grid",
        rule_notation = "F → F+F-F-F+F (120°)",
    ),
    # 100. Leaf Skeleton
    (
        name = "Leaf Skeleton",
        category = "Artistic Patterns",
        axiom = LString("X"),
        rules = RuleSet([
            Rule(LSymbol('X'), LString("F[+X][-X]FX")),
            Rule(LSymbol('F'), LString("FF")),
        ]),
        generations = 6,
        angle = 45.0,
        draw_chars = Set(['F']),
        linecolor = "#bd93f9",
        linewidth = 0.5,
        reference = "Leaf skeleton pattern",
        rule_notation = "X → F[+X][-X]FX, F → FF (45°)",
    ),
]

# ── Render a single entry ────────────────────────────────────────

"""
    render_entry(entry::GalleryEntry, outdir::String) -> String

Derive, interpret, and save an SVG for the given gallery entry.
Returns the filename of the saved SVG.
"""
function render_entry(entry::GalleryEntry, outdir::String)
    derived = derive(entry.axiom, entry.rules, entry.generations)
    processed = substitute_draw_symbols(derived, entry.draw_chars)
    segments = interpret2d(processed; angle=entry.angle)

    filename = entry_slug(entry.name) * ".svg"
    filepath = joinpath(outdir, filename)

    save_render(filepath, segments;
        linecolor = entry.linecolor,
        linewidth = entry.linewidth,
        backgroundcolor = "#111111",
        figsize = (600, 600),
        margin = 0.1,
    )

    filename
end

# ── Generate HTML gallery ────────────────────────────────────────

"""
    generate_gallery(outdir::String="gallery")

Render all gallery entries as SVGs and generate an HTML index page
with category sections and a sticky navigation bar.
"""
function generate_gallery(outdir::String="gallery")
    mkpath(outdir)

    # Group entries by category, preserving order of first appearance
    categories = String[]
    grouped = Dict{String, Vector{GalleryEntry}}()
    for entry in GALLERY
        if !haskey(grouped, entry.category)
            push!(categories, entry.category)
            grouped[entry.category] = GalleryEntry[]
        end
        push!(grouped[entry.category], entry)
    end

    # Render all SVGs and build card HTML grouped by category
    sections_html = String[]

    for cat in categories
        entries = grouped[cat]
        cards = String[]

        for entry in entries
            println("Rendering $(entry.name)...")
            filename = render_entry(entry, outdir)
            cat_id = entry_slug(cat)

            card = """
            <div class="card">
                <img src="$(filename)" alt="$(entry.name)" loading="lazy">
                <div class="info">
                    <h3>$(entry.name)</h3>
                    <code>$(entry.rule_notation)</code>
                    <p class="ref">$(entry.reference)</p>
                </div>
            </div>"""
            push!(cards, card)
        end

        cat_id = entry_slug(cat)
        section = """
    <section id="$(cat_id)">
        <h2 class="category-header">$(cat) <span class="count">($(length(entries)))</span></h2>
        <div class="grid">
$(join(cards, "\n"))
        </div>
    </section>"""
        push!(sections_html, section)
    end

    # Build navigation
    nav_links = String[]
    for cat in categories
        cat_id = entry_slug(cat)
        push!(nav_links, """        <a href="#$(cat_id)">$(cat)</a>""")
    end

    html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Physis — L-System Gallery</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: #0a0a0f;
            color: #e0e0e0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            padding: 2rem;
            padding-top: 5rem;
        }
        h1 {
            text-align: center;
            font-size: 2rem;
            margin-bottom: 0.5rem;
            color: #f8f8f2;
        }
        .subtitle {
            text-align: center;
            color: #6272a4;
            margin-bottom: 2rem;
            font-size: 0.9rem;
        }
        nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background: #14141e;
            border-bottom: 1px solid #2a2a3a;
            padding: 0.75rem 2rem;
            display: flex;
            gap: 1.5rem;
            justify-content: center;
            z-index: 100;
            flex-wrap: wrap;
        }
        nav a {
            color: #bd93f9;
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.2s;
        }
        nav a:hover { color: #ff79c6; }
        section { margin-bottom: 3rem; }
        .category-header {
            font-size: 1.5rem;
            color: #f8f8f2;
            margin-bottom: 1rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #2a2a3a;
        }
        .category-header .count {
            font-size: 0.9rem;
            color: #6272a4;
            font-weight: normal;
        }
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 1.5rem;
            max-width: 1400px;
            margin: 0 auto;
        }
        .card {
            background: #1e1e2e;
            border-radius: 12px;
            overflow: hidden;
            transition: transform 0.2s;
        }
        .card:hover { transform: translateY(-4px); }
        .card img {
            width: 100%;
            height: auto;
            display: block;
        }
        .info {
            padding: 1rem;
        }
        .info h3 {
            font-size: 1.1rem;
            margin-bottom: 0.5rem;
            color: #f8f8f2;
        }
        .info code {
            display: block;
            font-size: 0.85rem;
            color: #bd93f9;
            margin-bottom: 0.5rem;
            word-break: break-all;
        }
        .info .ref {
            font-size: 0.75rem;
            color: #6272a4;
        }
    </style>
</head>
<body>
    <nav>
$(join(nav_links, "\n"))
    </nav>
    <h1>Physis — L-System Gallery</h1>
    <p class="subtitle">100 L-systems from <em>The Algorithmic Beauty of Plants</em> and classic fractals</p>
$(join(sections_html, "\n"))
</body>
</html>"""

    index_path = joinpath(outdir, "index.html")
    write(index_path, html)
    println("Gallery written to $(index_path)")
    index_path
end

# ── Main entry point ─────────────────────────────────────────────

if abspath(PROGRAM_FILE) == @__FILE__
    outdir = length(ARGS) > 0 ? ARGS[1] : "gallery"
    generate_gallery(outdir)
end
