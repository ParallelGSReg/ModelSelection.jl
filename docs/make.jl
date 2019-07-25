using Distributions, Documenter, GLM, StatsBase

makedocs(
    format = Documenter.HTML(),
    sitename = "ModelSelection",
    modules = [ModelSelection],
    pages = [
        "Home" => "index.md"
    ],
    debug = true,
)

deploydocs(
    repo   = "github.com/ParallelGSReg/ModelSelection.jl",
)