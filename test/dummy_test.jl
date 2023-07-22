using Pkg
Pkg.activate(".")
using CSV, DataFrames, Distributions
using ModelSelection

data = CSV.read("test/data/test_panel_database.csv", DataFrame)
@time model = ModelSelection.gsr(
    :ols,
    "y x1 x2 x2",
    data,
    time=:time,
    residualtest=true,
)
ModelSelection.save_csv("result.csv", model)
println(model)
