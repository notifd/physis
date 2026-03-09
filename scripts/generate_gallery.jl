"""
    generate_gallery.jl — Generate an HTML gallery of 100 classic L-systems

Renders all registered species from the Physis catalog as SVGs,
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

# ── Slug helper ──────────────────────────────────────────────────

"""
    entry_slug(entry_name::String) -> String

Convert an entry name to a URL/filename-safe slug.
"""
function entry_slug(entry_name::String)
    s = replace(lowercase(entry_name), r"[^a-z0-9]+" => "-")
    strip(s, '-')
end

# ── Category display names ───────────────────────────────────────

const CATEGORY_DISPLAY_NAMES = Dict{Symbol, String}(
    :fractal_curves => "Fractal Curves",
    :dragon_family => "Dragon Family",
    :sierpinski_family => "Sierpinski Family",
    :space_filling => "Space-Filling Curves",
    :plants_trees => "Plants & Trees",
    :artistic_patterns => "Artistic Patterns",
)

# Category ordering for gallery display
const CATEGORY_ORDER = [
    :fractal_curves,
    :dragon_family,
    :sierpinski_family,
    :space_filling,
    :plants_trees,
    :artistic_patterns,
]

# ── Build GALLERY from species catalog ────────────────────────────

"""
    species_to_gallery_entry(def::LSystemDef) -> GalleryEntry

Convert an LSystemDef from the species catalog to a GalleryEntry NamedTuple.
"""
function species_to_gallery_entry(def::LSystemDef)
    (
        name = def.name,
        category = get(CATEGORY_DISPLAY_NAMES, def.category, string(def.category)),
        axiom = def.axiom,
        rules = def.rules,
        generations = def.generations,
        angle = def.angle,
        draw_chars = def.draw_chars,
        linecolor = get(def.metadata, :linecolor, "#8be9fd"),
        linewidth = get(def.metadata, :linewidth, 0.5),
        reference = get(def.metadata, :reference, ""),
        rule_notation = get(def.metadata, :rule_notation, ""),
    )
end

# Build gallery in category order, then alphabetical within each category
const GALLERY = GalleryEntry[
    species_to_gallery_entry(def)
    for cat in CATEGORY_ORDER
    for def in list_species(; category=cat)
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
