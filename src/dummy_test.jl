using CSV, ModelSelection

data = CSV.read("data/visitors.csv")

data = ModelSelection.gsr(
    "australia china japan uk", 
    data,
    intercept=true,
    time=:date,
    fe_sqr=[:uk, :china],
    fe_log=[:japan],
    fe_inv=:uk,
    preliminaryselection=:lasso,
    outsample=10,
    criteria=[:aic, :aicc],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=true,
    kfoldcrossvalidation=true,
    numfolds=10,
    # TODO exportcsv="visitors_output.csv",
    # TODO exportlatex="latex.zip"
)
