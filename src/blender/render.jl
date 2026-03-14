"""
    blender/render.jl — Julia API for Blender Cycles photorealistic rendering

Provides functions to find Blender, generate render scripts from templates,
and invoke Blender headless to produce photorealistic PNGs from GLB files.
"""

using StableRNGs

# ── Template path ─────────────────────────────────────────────────

const PHOTOREALISTIC_TEMPLATE = joinpath(@__DIR__, "templates", "photorealistic.py")

# ── find_blender ──────────────────────────────────────────────────

"""
    find_blender() -> Union{String, Nothing}

Search for the Blender executable. Checks (in order):
1. `ENV["BLENDER_PATH"]`
2. Platform-specific default paths
3. `Sys.which("blender")`

Returns the path if found, `nothing` otherwise.
"""
function find_blender()::Union{String, Nothing}
    # 1. Environment variable
    if haskey(ENV, "BLENDER_PATH")
        path = ENV["BLENDER_PATH"]
        isfile(path) && return path
    end

    # 2. Platform defaults
    if Sys.isapple()
        for candidate in [
            "/Applications/Blender.app/Contents/MacOS/Blender",
            expanduser("~/Applications/Blender.app/Contents/MacOS/Blender"),
        ]
            isfile(candidate) && return candidate
        end
    elseif Sys.islinux()
        for candidate in [
            "/usr/bin/blender",
            "/snap/bin/blender",
            expanduser("~/blender/blender"),
        ]
            isfile(candidate) && return candidate
        end
    elseif Sys.iswindows()
        for candidate in [
            raw"C:\Program Files\Blender Foundation\Blender\blender.exe",
            raw"C:\Program Files (x86)\Blender Foundation\Blender\blender.exe",
        ]
            isfile(candidate) && return candidate
        end
    end

    # 3. PATH lookup
    which_result = Sys.which("blender")
    which_result !== nothing && isfile(which_result) && return which_result

    return nothing
end

# ── generate_blender_script ──────────────────────────────────────

"""
    generate_blender_script(; glb_path, output_path, resolution=(1920,1080),
        samples=128, camera_distance_factor=2.5, bark_color=(0.35, 0.25, 0.15),
        ground_plane=true) -> String

Read the photorealistic template and replace all `{{PLACEHOLDER}}` markers.
Returns the complete Python script as a string.
"""
function generate_blender_script(;
    glb_path::AbstractString,
    output_path::AbstractString,
    resolution::Tuple{Int, Int}=(1920, 1080),
    samples::Int=128,
    camera_distance_factor::Real=2.5,
    bark_color::Tuple{Real, Real, Real}=(0.35, 0.25, 0.15),
    ground_plane::Bool=true,
)::String
    template = read(PHOTOREALISTIC_TEMPLATE, String)

    script = template
    script = replace(script, "{{GLB_PATH}}" => glb_path)
    script = replace(script, "{{OUTPUT_PATH}}" => output_path)
    script = replace(script, "{{RESOLUTION_X}}" => string(resolution[1]))
    script = replace(script, "{{RESOLUTION_Y}}" => string(resolution[2]))
    script = replace(script, "{{SAMPLES}}" => string(samples))
    script = replace(script, "{{CAMERA_DISTANCE_FACTOR}}" => string(Float64(camera_distance_factor)))
    script = replace(script, "{{BARK_COLOR_R}}" => string(Float64(bark_color[1])))
    script = replace(script, "{{BARK_COLOR_G}}" => string(Float64(bark_color[2])))
    script = replace(script, "{{BARK_COLOR_B}}" => string(Float64(bark_color[3])))
    script = replace(script, "{{GROUND_PLANE}}" => ground_plane ? "True" : "False")

    return script
end

# ── render_photorealistic ────────────────────────────────────────

"""
    render_photorealistic(glb_path, output_path; resolution=(1920,1080),
        samples=128, camera_distance_factor=2.5, bark_color=(0.35, 0.25, 0.15),
        ground_plane=true, blender_path=nothing, timeout=300) -> Union{String, Nothing}

Generate a Blender script, write it to a tempfile, and invoke Blender in
background mode to render a photorealistic PNG from the given GLB.

Returns `output_path` on success, `nothing` on failure (logged as `@warn`).
Never throws — failures are non-fatal.
"""
function render_photorealistic(
    glb_path::AbstractString,
    output_path::AbstractString;
    resolution::Tuple{Int, Int}=(1920, 1080),
    samples::Int=128,
    camera_distance_factor::Real=2.5,
    bark_color::Tuple{Real, Real, Real}=(0.35, 0.25, 0.15),
    ground_plane::Bool=true,
    blender_path::Union{String, Nothing}=nothing,
    timeout::Int=300,
)::Union{String, Nothing}
    # Validate GLB exists
    if !isfile(glb_path)
        @warn "GLB file not found, skipping photorealistic render" glb_path
        return nothing
    end

    # Find Blender
    blender = blender_path !== nothing ? blender_path : find_blender()
    if blender === nothing || !isfile(blender)
        @warn "Blender not found, skipping photorealistic render"
        return nothing
    end

    # Generate script
    script = generate_blender_script(;
        glb_path=abspath(glb_path),
        output_path=abspath(output_path),
        resolution=resolution,
        samples=samples,
        camera_distance_factor=camera_distance_factor,
        bark_color=bark_color,
        ground_plane=ground_plane,
    )

    # Write script to temp file
    script_path = tempname() * ".py"
    try
        write(script_path, script)

        # Invoke Blender
        cmd = `$blender --background --python $script_path`
        proc = run(pipeline(cmd; stdout=devnull, stderr=devnull); wait=false)

        # Wait with timeout
        timer = Timer(timeout)
        @async begin
            wait(timer)
            if process_running(proc)
                kill(proc)
                @warn "Blender render timed out after $(timeout)s" glb_path
            end
        end

        wait(proc)
        close(timer)

        if proc.exitcode != 0
            @warn "Blender render failed" exitcode=proc.exitcode glb_path
            return nothing
        end

        if isfile(output_path)
            return output_path
        else
            @warn "Blender render completed but output file not found" output_path
            return nothing
        end
    catch e
        @warn "Blender render error" exception=(e, catch_backtrace())
        return nothing
    finally
        rm(script_path; force=true)
    end
end

# ── render_species_photorealistic ────────────────────────────────

"""
    render_species_photorealistic(species_name, outdir;
        resolution=(1920,1080), samples=128,
        blender_path=nothing) -> Union{String, Nothing}

End-to-end: look up species → generate GLB → render photorealistic PNG.
Uses `:blender_bark_color` and `:blender_samples` from species metadata if present.
Returns the PNG path on success, `nothing` on failure.
"""
function render_species_photorealistic(
    species_name::AbstractString,
    outdir::AbstractString;
    resolution::Tuple{Int, Int}=(1920, 1080),
    samples::Int=128,
    blender_path::Union{String, Nothing}=nothing,
)::Union{String, Nothing}
    def = get_species(species_name)
    if def === nothing
        @warn "Species not found" species_name
        return nothing
    end

    if !get(def.metadata, :is_3d, false)
        @warn "Species is not a 3D species, skipping photorealistic render" species_name
        return nothing
    end

    mkpath(outdir)
    slug = species_slug(def.name)
    glb_path = joinpath(outdir, slug * ".glb")
    png_path = joinpath(outdir, slug * "_photo.png")

    # Generate GLB
    color = get(def.metadata, :glb_color, (0.18, 0.55, 0.22))
    base_radius = get(def.metadata, :glb_base_radius, 0.05)
    taper = get(def.metadata, :glb_taper, 0.7)
    gens = get(def.metadata, :glb_generations, def.generations)
    step_scale = get(def.metadata, :step_scale, 1.0)

    try
        render_lsystem_3d(
            def.axiom, def.rules, gens;
            angle=def.angle,
            step_scale=step_scale,
            base_radius=base_radius,
            taper=taper,
            output_path=glb_path,
            color=color,
            rng=StableRNG(42),
        )
    catch e
        @warn "Failed to generate GLB for species" species_name exception=(e, catch_backtrace())
        return nothing
    end

    # Render photorealistic
    bark_color = get(def.metadata, :blender_bark_color, color)
    render_samples = get(def.metadata, :blender_samples, samples)
    camera_distance = get(def.metadata, :blender_camera_distance, 2.5)

    return render_photorealistic(
        glb_path, png_path;
        resolution=resolution,
        samples=render_samples,
        camera_distance_factor=camera_distance,
        bark_color=bark_color,
        blender_path=blender_path,
    )
end
