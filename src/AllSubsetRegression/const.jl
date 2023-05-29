const ALLSUBSETREGRESSION_EXTRAKEY = :allsubsetregression
const CRITERIA_DEFAULT = Vector{Symbol}()
const FIXEDVARIABLES_DEFAULT = nothing
const INSAMPLE_MIN = 20
const MODELAVG_DEFAULT = false
const ORDERRESULTS_DEFAULT = false
const OUTSAMPLE_DEFAULT = 0
const RESIDUALTEST_DEFAULT = false
const TTEST_DEFAULT = false
const ZTEST_DEFAULT = false

const EQUATION_GENERAL_INFORMATION = [:nobs, :ncoef, :sse, :r2, :F, :rmse, :r2adj]
const INDEX = :index
const ORDER = :order
const RESIDUAL_TESTS_CROSS = [:jbtest, :wtest]
const RESIDUAL_TESTS_TIME = [:jbtest, :wtest, :bgtest]
const WEIGHT = :weight

const AVAILABLE_CRITERIA = Dict(
    :aic => Dict(
        "verbose_title" => "AIC",
        "verbose_show" => true,
        "index" => -1,
        "order" => 1,
    ),
    :aicc => Dict(
        "verbose_title" => "AIC Corrected",
        "verbose_show" => true,
        "index" => -1,
        "order" => 2,
    ),
    :bic => Dict(
        "verbose_title" => "BIC",
        "verbose_show" => true,
        "index" => -1,
        "order" => 3,
    ),
    :cp => Dict(
        "verbose_title" => "Mallows's Cp",
        "verbose_show" => true,
        "index" => -,
        "order" => 4,
    ),
    :loglikelihood => Dict(
        "verbose_title" => "Log Likelihood",
        "verbose_show" => true,
        "index" => -1,
        "order" => 5,
    ),
    :r2adj => Dict(
        "verbose_title" => "Adjusted R²",
        "verbose_show" => false,
        "index" => 1,
        "order" => 6,
    ),
    :rmse => Dict(
        "verbose_title" => "RMSE",
        "verbose_show" => true,
        "index" => -1,
        "order" => 7,
    ),
    :rmseout => Dict(
        "verbose_title" => "RMSE OUT",
        "verbose_show" => true,
        "index" => -1,
        "order" => 8,
    ),
    :roc => Dict(
        "verbose_title" => "ROC",
        "verbose_show" => true,
        "index" => -1,
        "order" => 9,
    ),
    :sse => Dict(
        "verbose_title" => "SSE",
        "verbose_show" => true,
        "index" => -1,
        "order" => 10,
    ),
)

const AVAILABLE_LOGIT_CRITERIA = [:aic, :aicc, :bic, :cp, :loglikelihood, :roc]
const AVAILABLE_OLS_CRITERIA = [:aic, :aicc, :bic, :cp, :r2adj, :rmse, :rmseout, :sse]

const SUMMARY_VARIABLES = Dict(
    :nobs =>
        Dict("verbose_title" => "Observations", "verbose_show" => true, "order" => 1),
    :F => Dict("verbose_title" => "F-statistic", "verbose_show" => true, "order" => 2),
)
