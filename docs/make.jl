using Documenter, DocumenterTools
using DataFrames
using ModelSelection
using ModelSelection: Preprocessing, FeatureExtraction

# The DOCSARGS environment variable can be used to pass additional arguments to make.jl.
# This is useful on CI, if you need to change the behavior of the build slightly but you
# can not change the .travis.yml or make.jl scripts any more (e.g. for a tag build).
if haskey(ENV, "DOCSARGS")
    for arg in split(ENV["DOCSARGS"])
        (arg in ARGS) || push!(ARGS, arg)
    end
end

makedocs(
    format = Documenter.HTML(
        prettyurls = false,
        assets = ["assets/favicon.ico"],
    ),
    source = "src",
    build   = "build",
    clean   = true,
    modules = [ModelSelection, Preprocessing, FeatureExtraction],
    sitename = "ModelSelection.jl",
    pages = [
        "Home" => "index.md",
        "Getting Started" => "start.md",
        "Usage" => "usage.md",
        "Modules" => Any[
            "Preprocessing" => Any[
                "Module" => "modules/Preprocessing/index.md",
                "modules/Preprocessing/core.md",
                "modules/Preprocessing/utils.md",
                "modules/Preprocessing/strings.md",
                "modules/Preprocessing/const.md"
            ],
            "FeatureExtraction" => Any[
                "Module" => "modules/FeatureExtraction/index.md",
                "modules/FeatureExtraction/core.md",
                "modules/FeatureExtraction/utils.md",
                "modules/FeatureExtraction/strings.md",
                "modules/FeatureExtraction/const.md"
            ],
        ],
        "Contributing" => "contributing.md",
        "News" => "news.md",
        "Todo" => "todo.md",
        "License" => "license.md",
    ],
)

deploydocs(
    repo = "github.com/ParallelGSReg/ModelSelection.jl.git",
    versions = nothing,
)
