"""
    registry.jl — Species registry for L-system definitions

Global registry that stores all registered L-system species definitions.
Species are registered at module load time from the definition files.
"""

# ──────────────────────────────────────────────────────────────────
# Global registry
# ──────────────────────────────────────────────────────────────────

const SPECIES_REGISTRY = Dict{String, LSystemDef}()

# ──────────────────────────────────────────────────────────────────
# Registry operations
# ──────────────────────────────────────────────────────────────────

"""
    register_species!(def::LSystemDef) -> LSystemDef

Register an L-system species definition in the global registry.
Warns if overwriting an existing entry with the same name.
"""
function register_species!(def::LSystemDef)
    if haskey(SPECIES_REGISTRY, def.name)
        @warn "Overwriting existing species" name=def.name
    end
    SPECIES_REGISTRY[def.name] = def
    def
end

"""
    get_species(name::String) -> Union{LSystemDef, Nothing}

Look up a species by name. Returns `nothing` if not found.
"""
function get_species(name::String)::Union{LSystemDef, Nothing}
    get(SPECIES_REGISTRY, name, nothing)
end

"""
    list_species(; category=nothing) -> Vector{LSystemDef}

Return all registered species, sorted by name.
Optionally filter by category symbol.
"""
function list_species(; category::Union{Symbol, Nothing}=nothing)::Vector{LSystemDef}
    all_species = collect(values(SPECIES_REGISTRY))
    if category !== nothing
        filter!(s -> s.category == category, all_species)
    end
    sort!(all_species; by=s -> s.name)
    all_species
end

"""
    list_categories() -> Vector{Symbol}

Return sorted list of all categories present in the registry.
"""
function list_categories()::Vector{Symbol}
    cats = unique([s.category for s in values(SPECIES_REGISTRY)])
    sort!(cats)
    cats
end
