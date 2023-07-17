using Pkg
Pkg.activate(".")
using CSV, DataFrames, Distributions
using ModelSelection

data = CSV.read("test/data/15x1000_logit.csv", DataFrame)
model = ModelSelection.gsr(
    :logit,
    "y x1 x2 x3 x4 x5",
    data,
    fixedvariables=:x6,
    # modelavg=true,
    kfoldcrossvalidation=true,
    numfolds=20,
)
ModelSelection.save_csv("result.csv", model)
println(model)

"""
ModelSelection.save("result.jld", model) 
results = ModelSelection.load("result.jld")
"""
