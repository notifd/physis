"""
    generate_gallery.jl — Generate an HTML gallery of 100 classic L-systems

Renders all registered species from the Physis catalog as SVGs,
and generates a self-contained HTML gallery page with category navigation.
Plant & tree species also get interactive 3D GLB viewers via model-viewer
and photorealistic Blender Cycles renders (when Blender is available).

Usage:
    julia --project=. scripts/generate_gallery.jl [outdir]

Default output directory: gallery/

Reference: ABOP §1.3, §1.5, Fig 1.24
"""

using Physis
using CairoMakie
using Random
using StableRNGs

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
    is_3d::Bool
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

# ── 3D rendering helpers ─────────────────────────────────────────

"""
    is_3d_species(entry) -> Bool

Return true if the gallery entry is a plant/tree species that should get a 3D render.
"""
is_3d_species(entry) = entry.is_3d

const DEFAULT_GLB_COLOR = (0.18, 0.55, 0.22)
const DEFAULT_GLB_BASE_RADIUS = 0.05
const DEFAULT_GLB_TAPER = 0.7

"""
    render_entry_3d(entry, def::LSystemDef, outdir::String) -> Union{String, Nothing}

Render a 3D GLB file for the given gallery entry using the species definition.
Returns the GLB filename on success, `nothing` on failure (logged as warning).
"""
function render_entry_3d(entry, def::LSystemDef, outdir::String)
    filename = entry_slug(entry.name) * ".glb"
    filepath = joinpath(outdir, filename)

    color = get(def.metadata, :glb_color, DEFAULT_GLB_COLOR)
    base_radius = get(def.metadata, :glb_base_radius, DEFAULT_GLB_BASE_RADIUS)
    taper = get(def.metadata, :glb_taper, DEFAULT_GLB_TAPER)
    gens = get(def.metadata, :glb_generations, def.generations)
    step_scale = get(def.metadata, :step_scale, 1.0)

    try
        render_lsystem_3d(
            def.axiom, def.rules, gens;
            angle=def.angle,
            step_scale=step_scale,
            base_radius=base_radius,
            taper=taper,
            output_path=filepath,
            color=color,
            rng=StableRNG(42),
        )
        return filename
    catch e
        @warn "Failed to render 3D for $(entry.name)" exception=(e, catch_backtrace())
        return nothing
    end
end

# ── Photorealistic rendering helpers ─────────────────────────────

const DEFAULT_PHOTO_RESOLUTION = (1920, 1080)
const DEFAULT_PHOTO_SAMPLES = 128

"""
    render_entry_photorealistic(entry, def::LSystemDef, outdir::String;
        glb_filename::String) -> Union{String, Nothing}

Render a photorealistic PNG via Blender Cycles for the given gallery entry.
Requires Blender installed and the GLB file already generated.
Returns the PNG filename on success, `nothing` on failure.
"""
function render_entry_photorealistic(entry, def::LSystemDef, outdir::String;
    glb_filename::String)
    glb_path = joinpath(outdir, glb_filename)
    photo_filename = entry_slug(entry.name) * "_photo.png"
    photo_path = joinpath(outdir, photo_filename)

    bark_color = get(def.metadata, :blender_bark_color,
                     get(def.metadata, :glb_color, DEFAULT_GLB_COLOR))
    samples = get(def.metadata, :blender_samples, DEFAULT_PHOTO_SAMPLES)
    camera_distance = get(def.metadata, :blender_camera_distance, 2.5)

    result = render_photorealistic(
        glb_path, photo_path;
        resolution=DEFAULT_PHOTO_RESOLUTION,
        samples=samples,
        camera_distance_factor=camera_distance,
        bark_color=bark_color,
    )

    return result !== nothing ? photo_filename : nothing
end

# ── Card builders ────────────────────────────────────────────────

"""
    build_2d_card(entry, svg_filename::String) -> String

Build HTML for a 2D-only gallery card (fractals, etc).
"""
function build_2d_card(entry, svg_filename::String)
    """
            <div class="card">
                <img src="$(svg_filename)" alt="$(entry.name)" loading="lazy">
                <div class="info">
                    <h3>$(entry.name)</h3>
                    <code>$(entry.rule_notation)</code>
                    <p class="ref">$(entry.reference)</p>
                </div>
            </div>"""
end

"""
    build_3d_card(entry, svg_filename::String, glb_filename::String) -> String

Build HTML for a 3D+2D gallery card with tab toggle. 3D view is shown by default.
"""
function build_3d_card(entry, svg_filename::String, glb_filename::String)
    """
            <div class="card card-3d">
                <div class="media-tabs">
                    <button class="tab active" onclick="toggleView(this, '3d')">3D</button>
                    <button class="tab" onclick="toggleView(this, '2d')">2D</button>
                </div>
                <div class="media-view view-3d active">
                    <model-viewer src="$(glb_filename)" alt="$(entry.name) 3D model" auto-rotate camera-controls shadow-intensity="1" style="width:100%;height:300px;background:#111111;"></model-viewer>
                </div>
                <div class="media-view view-2d">
                    <img src="$(svg_filename)" alt="$(entry.name)" loading="lazy">
                </div>
                <div class="info">
                    <h3>$(entry.name)</h3>
                    <code>$(entry.rule_notation)</code>
                    <p class="ref">$(entry.reference)</p>
                </div>
            </div>"""
end

"""
    build_3d_photo_card(entry, svg_filename::String, glb_filename::String, photo_filename::String) -> String

Build HTML for a Photo+3D+2D gallery card with 3 tab toggle. Photo view is shown by default.
"""
function build_3d_photo_card(entry, svg_filename::String, glb_filename::String, photo_filename::String)
    """
            <div class="card card-3d">
                <div class="media-tabs">
                    <button class="tab active" onclick="toggleView(this, 'photo')">Photo</button>
                    <button class="tab" onclick="toggleView(this, '3d')">3D</button>
                    <button class="tab" onclick="toggleView(this, '2d')">2D</button>
                </div>
                <div class="media-view view-photo active">
                    <img src="$(photo_filename)" alt="$(entry.name) photorealistic render" loading="lazy">
                </div>
                <div class="media-view view-3d">
                    <model-viewer src="$(glb_filename)" alt="$(entry.name) 3D model" auto-rotate camera-controls shadow-intensity="1" style="width:100%;height:300px;background:#111111;"></model-viewer>
                </div>
                <div class="media-view view-2d">
                    <img src="$(svg_filename)" alt="$(entry.name)" loading="lazy">
                </div>
                <div class="info">
                    <h3>$(entry.name)</h3>
                    <code>$(entry.rule_notation)</code>
                    <p class="ref">$(entry.reference)</p>
                </div>
            </div>"""
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
        is_3d = get(def.metadata, :is_3d, false),
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

    # Build species lookup for 3D rendering
    species_lookup = Dict(def.name => def for def in list_species())

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

    # Render all SVGs (and GLBs for plants) and build card HTML
    sections_html = String[]

    for cat in categories
        entries = grouped[cat]
        cards = String[]

        for entry in entries
            println("Rendering $(entry.name)...")
            svg_filename = render_entry(entry, outdir)

            if is_3d_species(entry) && haskey(species_lookup, entry.name)
                def = species_lookup[entry.name]
                println("  Rendering 3D for $(entry.name)...")
                glb_filename = render_entry_3d(entry, def, outdir)
                if glb_filename !== nothing
                    # Attempt photorealistic render
                    println("  Rendering photorealistic for $(entry.name)...")
                    photo_filename = render_entry_photorealistic(entry, def, outdir;
                        glb_filename=glb_filename)
                    if photo_filename !== nothing
                        push!(cards, build_3d_photo_card(entry, svg_filename, glb_filename, photo_filename))
                    else
                        push!(cards, build_3d_card(entry, svg_filename, glb_filename))
                    end
                else
                    push!(cards, build_2d_card(entry, svg_filename))
                end
            else
                push!(cards, build_2d_card(entry, svg_filename))
            end
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
    <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.5.0/model-viewer.min.js"></script>
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
        .card-3d { position: relative; }
        .media-tabs {
            position: absolute;
            top: 8px;
            right: 8px;
            z-index: 10;
            display: flex;
            gap: 4px;
        }
        .tab {
            padding: 4px 10px;
            border: 1px solid #444;
            border-radius: 4px;
            background: #1e1e2e;
            color: #aaa;
            cursor: pointer;
            font-size: 0.75rem;
        }
        .tab.active {
            background: #bd93f9;
            color: #0a0a0f;
            border-color: #bd93f9;
        }
        .media-view { display: none; }
        .media-view.active { display: block; }
        .view-photo img {
            width: 100%;
            height: auto;
            display: block;
            object-fit: cover;
        }
    </style>
</head>
<body>
    <nav>
$(join(nav_links, "\n"))
    </nav>
    <h1>Physis — L-System Gallery</h1>
    <p class="subtitle">L-systems from <em>The Algorithmic Beauty of Plants</em> and classic fractals — plants with interactive 3D and photorealistic renders</p>
$(join(sections_html, "\n"))
    <script>
    function toggleView(btn, view) {
        var card = btn.closest('.card-3d');
        card.querySelectorAll('.tab').forEach(function(t) { t.classList.remove('active'); });
        card.querySelectorAll('.media-view').forEach(function(v) { v.classList.remove('active'); });
        btn.classList.add('active');
        card.querySelector('.view-' + view).classList.add('active');
    }
    </script>
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
