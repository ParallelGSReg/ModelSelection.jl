using Distributions, Documenter

makedocs(
    format = Documenter.HTML(),
    sitename = "Modelselection",
    modules = [GLM],
    pages = [
        "Home" => "index.md"
    ],
    debug = true,
)

deploydocs(
    repo   = "github.com/ParallelGSReg/ModelSelection.jl.git",
)