using CSV, ModelSelection, DataFrames, Distributions

data = CSV.read("test/data/visitors.csv", DataFrame)
p=0.3
N=size(data,1)
d=Binomial(1,p)
data[!,:y]=rand(d,N)

model =  ModelSelection.gsr(:logit, "y australia china japan", data, fixedvariables=[:uk], criteria = [:aic, :aicc])

ModelSelection.save_csv("result.csv", model)
ModelSelection.save("result.jld", model) 
results = ModelSelection.load("result.jld")
