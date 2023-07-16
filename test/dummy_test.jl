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
    #fe_sqr = [:japan, :china],
    #fe_log = [:japan, :china],
    #fe_inv = [:japan, :china],
    #fe_lag = Dict(:japan => 1),
    #interaction = [(:japan, :china)],
)
ModelSelection.save_csv("result.csv", model)
println(model)

"""
ModelSelection.save("result.jld", model) 
results = ModelSelection.load("result.jld")
"""
