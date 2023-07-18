using Pkg
Pkg.activate(".")
using CSV, DataFrames, Distributions
using ModelSelection

data = CSV.read("test/data/visitors.csv", DataFrame)
p = 0.3
N = size(data, 1)
d = Binomial(1, p)
data[!, :y] = rand(d, N)

model = ModelSelection.gsr(
    :ols,
    "australia china japan",
    fixedvariables=:uk,
    # modelavg=true,
    data,
    kfoldcrossvalidation=true,
    numfolds=20,
)

ModelSelection.save_csv("result.csv", model)
println(model)

"""
ModelSelection.save("result.jld", model) 
results = ModelSelection.load("result.jld")
"""
