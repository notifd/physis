"""
    generate_gallery.jl — Generate an HTML gallery of classic ABOP L-systems

Defines 10 classic L-systems from Prusinkiewicz & Lindenmayer (ABOP),
renders them as SVGs, and generates a self-contained HTML gallery page.

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

# ── Gallery entries: 10 classic ABOP L-systems ───────────────────

const GALLERY = GalleryEntry[
    # 1. Koch Curve — ABOP §1.3
    (
        name = "Koch Curve",
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
    # 3. Sierpinski Triangle — ABOP §1.3
    (
        name = "Sierpinski Triangle",
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
    # 4. Dragon Curve — ABOP §1.3
    (
        name = "Dragon Curve",
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
    # 5. Plant 1 — ABOP Fig 1.24a
    (
        name = "Plant 1",
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
    # 6. Plant 2 — ABOP Fig 1.24c
    (
        name = "Plant 2",
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
    # 7. Plant 3 — ABOP Fig 1.24d
    (
        name = "Plant 3",
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
    # 8. Plant 4 — ABOP Fig 1.24e
    (
        name = "Plant 4",
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
    # 9. Plant 5 — ABOP Fig 1.24f
    (
        name = "Plant 5",
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
    # 10. Hilbert Curve — ABOP §1.3
    (
        name = "Hilbert Curve",
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

Render all gallery entries as SVGs and generate an HTML index page.
"""
function generate_gallery(outdir::String="gallery")
    mkpath(outdir)

    cards_html = String[]

    for entry in GALLERY
        println("Rendering $(entry.name)...")
        filename = render_entry(entry, outdir)

        card = """
        <div class="card">
            <img src="$(filename)" alt="$(entry.name)" loading="lazy">
            <div class="info">
                <h2>$(entry.name)</h2>
                <code>$(entry.rule_notation)</code>
                <p class="ref">$(entry.reference)</p>
            </div>
        </div>"""
        push!(cards_html, card)
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
        .info h2 {
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
    <h1>Physis — L-System Gallery</h1>
    <p class="subtitle">Classic L-systems from <em>The Algorithmic Beauty of Plants</em> (Prusinkiewicz &amp; Lindenmayer)</p>
    <div class="grid">
$(join(cards_html, "\n"))
    </div>
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
