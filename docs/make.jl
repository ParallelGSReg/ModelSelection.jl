using Pkg
Pkg.activate(".")
using ModelSelection, ModelSelection.AllSubsetRegression

using Distributions, Documenter

makedocs(
    #root = "/",
    #format = Documenter.HTML(),
    sitename = "Modelselection.jl",
    modules = [ModelSelection, ModelSelection.AllSubsetRegression],
    repo = "https://github.com/ParallelGSReg/ModelSelection.j",
    source = "src",
    doctest = true,
    clean   = true,
    build   = "build",
    debug = true,
    
    pages = ["Home" => "index.md"],
)

#deploydocs(repo = "github.com/ParallelGSReg/ModelSelection.jl.git")

#makedocs(...,
#    format = Documenter.HTML(
#        prettyurls = get(ENV, "CI", nothing) == "true"
#    )
#)