#create a function to run ModelSelection.jl
using CSV, DataFrames, ModelSelection

data = CSV.read("15x1000.csv", DataFrame)

model = ModelSelection.gsr(
    :ols,
    "y x*", 
    data,
    intercept=true,
    fe_sqr=[:x2, :x3],
    fe_log=:x12,
    fe_inv=:x10,
    preliminaryselection=:lasso,
    criteria=[:aic, :aicc],
    orderresults=true
)

using JLD
aux= load("ModelSelectionData_data.jld")
model = aux["ModelSelectionData"]
aux2= load("ModelSelectionData_originaldata.jld")
model2 = aux2["ModelSelectionOriginalData"]