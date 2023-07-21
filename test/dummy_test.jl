using Pkg
Pkg.activate(".")
using CSV, DataFrames, Distributions
using ModelSelection

data = CSV.read("test/data/15x1000.csv", DataFrame)
@time model = ModelSelection.gsr(
    :ols,
    "y x1 x2 x3 x4",
    data,
    method=:svd_32,
)



"""
using Pkg
Pkg.activate(".")
using CSV, DataFrames, Distributions
using ModelSelection

data = CSV.read("test/data/15x1000.csv", DataFrame)
@time model = ModelSelection.gsr(
    :ols,
    "y x1 x2",
    data,
    modelavg=true,
    method=:cho_64,
)

ModelSelection.save_csv("result.csv", model)
println(model)


ModelSelection.save("result.jld", model) 
results = ModelSelection.load("result.jld")
"""
