using CSV, ModelSelection, Distributed

data = CSV.read("test/data/small.csv")

data = ModelSelection.Preprocessing.input("y x*", data, intercept=true)
result = ModelSelection.AllSubsetRegression.ols(
    data,
    outsample=10,
    criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :sse, :rmseout],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=false
)
ModelSelection.OutputDecoration.csv_res(result.results[1], "salida.csv")
