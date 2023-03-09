using CSV, ModelSelection, DataFrames

data = CSV.read("test/data/visitors.csv", DataFrame)

model = ModelSelection.gsr(
    :logit,
    "australia china japan uk", 
    data,
    criteria=[:aic, :aicc],
)
