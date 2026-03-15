using Documenter
using Physis

makedocs(
    sitename = "Physis.jl",
    format = Documenter.HTML(prettyurls=false),
    modules = [Physis],
    pages = [
        "Home" => "index.md",
        "Algorithms" => "algorithms.md",
        "Species Catalog" => "species.md",
        "API Reference" => "api.md",
        "Tutorials" => [
            "Your First L-System" => "tutorials/first_lsystem.md",
            "Adding a Species" => "tutorials/add_species.md",
            "Photorealistic Renders" => "tutorials/photorealistic.md",
        ],
    ],
)
