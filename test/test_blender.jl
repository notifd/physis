"""
Tests for Blender Cycles photorealistic rendering integration.

Tier 1 tests run without Blender. Tier 2 tests require Blender installed.
"""

@testset "Blender Photorealistic Rendering" begin

    # ── Tier 1: No Blender required ──────────────────────────────────

    @testset "find_blender" begin
        result = find_blender()
        # Should return String or Nothing, never error
        @test result isa Union{String, Nothing}
        if result !== nothing
            @test isfile(result)
        end
    end

    @testset "generate_blender_script produces valid Python" begin
        script = generate_blender_script(
            glb_path="/tmp/test.glb",
            output_path="/tmp/test.png",
            resolution=(1920, 1080),
            samples=64,
            camera_distance_factor=2.5,
            bark_color=(0.35, 0.25, 0.15),
            ground_plane=true,
        )

        # Script is a non-empty string
        @test script isa String
        @test length(script) > 100

        # All placeholders replaced (no {{...}} remaining)
        @test !occursin("{{", script)
        @test !occursin("}}", script)

        # Contains expected Blender API calls
        @test occursin("import bpy", script)
        @test occursin("bpy.ops.import_scene.gltf", script)
        @test occursin("CYCLES", script)
        @test occursin("render.render", script)
        @test occursin("/tmp/test.glb", script)
        @test occursin("/tmp/test.png", script)

        # Resolution and samples injected
        @test occursin("1920", script)
        @test occursin("1080", script)
        @test occursin("64", script)

        # Bark color injected
        @test occursin("0.35", script)
        @test occursin("0.25", script)
        @test occursin("0.15", script)

        # Camera distance factor injected
        @test occursin("2.5", script)

        # Ground plane enabled
        @test occursin("shadow_catcher", script) || occursin("is_shadow_catcher", script)
    end

    @testset "generate_blender_script without ground plane" begin
        script = generate_blender_script(
            glb_path="/tmp/test.glb",
            output_path="/tmp/test.png",
            ground_plane=false,
        )
        @test !occursin("shadow_catcher", script) || occursin("ground_plane = False", script)
    end

    @testset "render_photorealistic returns nothing for invalid blender" begin
        mktempdir() do tmpdir
            glb_path = joinpath(tmpdir, "test.glb")
            output_path = joinpath(tmpdir, "test.png")
            # Create a dummy GLB file
            write(glb_path, "dummy")

            result = render_photorealistic(
                glb_path, output_path;
                blender_path="/nonexistent/blender",
            )
            @test result === nothing
        end
    end

    @testset "render_photorealistic returns nothing for missing GLB" begin
        mktempdir() do tmpdir
            output_path = joinpath(tmpdir, "test.png")
            result = render_photorealistic(
                "/nonexistent/file.glb", output_path,
            )
            @test result === nothing
        end
    end

    # ── Tier 2: Requires Blender ─────────────────────────────────────

    blender = find_blender()

    if blender !== nothing
        @testset "End-to-end Blender render" begin
            using StableRNGs

            mktempdir() do tmpdir
                # Generate a GLB from a 3D species
                species_3d = [def for def in list_species() if get(def.metadata, :is_3d, false)]
                @test !isempty(species_3d)
                def = first(species_3d)

                glb_path = joinpath(tmpdir, "test_tree.glb")
                color = get(def.metadata, :glb_color, (0.18, 0.55, 0.22))
                gens = get(def.metadata, :glb_generations, def.generations)
                step_scale = get(def.metadata, :step_scale, 1.0)

                render_lsystem_3d(
                    def.axiom, def.rules, gens;
                    angle=def.angle,
                    step_scale=step_scale,
                    output_path=glb_path,
                    color=color,
                    rng=StableRNG(42),
                )
                @test isfile(glb_path)

                # Render photorealistic PNG
                png_path = joinpath(tmpdir, "test_render.png")
                result = render_photorealistic(
                    glb_path, png_path;
                    resolution=(640, 480),
                    samples=16,
                    blender_path=blender,
                    timeout=120,
                )

                @test result !== nothing
                @test result == png_path
                @test isfile(png_path)
                @test filesize(png_path) > 0

                # Verify PNG magic bytes
                png_header = read(png_path, 8)
                @test png_header[1:4] == UInt8[0x89, 0x50, 0x4e, 0x47]
            end
        end

        @testset "render_species_photorealistic end-to-end" begin
            mktempdir() do tmpdir
                species_3d = [def for def in list_species() if get(def.metadata, :is_3d, false)]
                def = first(species_3d)

                result = render_species_photorealistic(
                    def.name, tmpdir;
                    resolution=(640, 480),
                    samples=16,
                    blender_path=blender,
                )

                @test result !== nothing
                @test isfile(result)
                @test filesize(result) > 0
            end
        end
    else
        @info "Blender not found — skipping Tier 2 integration tests"
    end
end
