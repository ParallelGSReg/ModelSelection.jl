using Pkg
Pkg.activate(".")
using CSV, DataFrames, Distributions
using ModelSelection

data = CSV.read("test/data/visitors.csv", DataFrame)
p = 0.3
N = size(data, 1)
d = Binomial(1, p)
data[!, :y] = rand(d, N)

function job_notify(message::String, data::Union{Any,Nothing} = nothing)
    println(message, data)
end

model = ModelSelection.gsr(
    :ols,
    "australia china japan",
    data,
    fixedvariables = [:uk],
    ttest = true,
    modelavg = true,
    criteria = [:aic, :aicc],
    kfoldcrossvalidation = true,
    notify = job_notify,
)

print(model)
 
"""
ModelSelection.save_csv("result.csv", model)
ModelSelection.save("result.jld", model) 
results = ModelSelection.load("result.jld")
"""
