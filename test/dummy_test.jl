using Pkg
Pkg.activate(".")
using CSV, DataFrames, Distributions
using ModelSelection

data = CSV.read("test/data/test_time_database.csv", DataFrame)
@time model = ModelSelection.gsr(
    :logit,
    "y x1 x2",
    data,
    time=:time,
    residualtest=true,
)

