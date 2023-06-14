const REPO = "https://github.com/ParallelGSReg/ModelSelection.jl.git"

using Documenter, DocumenterTools
using ModelSelection, ModelSelection.AllSubsetRegression

makedocs(
    source = "src",
    build   = "build",
    clean   = true,
    modules = [ModelSelection, ModelSelection.AllSubsetRegression],
    sitename = "Modelselection.jl",
    # expandfirst
    pages = [
        "Home" => "index.md",
    ],
)

deploydocs(repo = REPO)
