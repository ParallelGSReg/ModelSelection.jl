const CROSSVALIDATION_EXTRAKEY = :crossvalidation
const KFOLDCROSSVALIDATION_DEFAULT = false
const NUMFOLDS_DEFAULT = 5
const TESTSETSHARE_DEFAULT = 0.15
const SUMMARY_VARIABLES = Dict(
    :nobs =>
        Dict("verbose_title" => "Observations", "verbose_show" => true, "order" => 1),
    :rmseout =>
        Dict("verbose_title" => "RMSE OUT ", "verbose_show" => true, "order" => 2),
)
# It should be named differently
