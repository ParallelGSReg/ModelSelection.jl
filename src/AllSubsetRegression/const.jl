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
)

const OLS_CRITERIA_AVAILABLE = Vector{Symbol}([:aic, :aicc, :bic, :cp, :r2adj, :rmse, :rmseout, :sse])
const OLS_CRITERIA_DEFAULT = Vector{Symbol}([:r2adj])
const OLS_EQUATION_GENERAL_INFORMATION = Vector{Symbol}([:nobs, :ncoef, :r2, :F, :rmse, :r2adj, :sse])

const LOGIT_CRITERIA_AVAILABLE = Vector{Symbol}([:aic, :aicc, :bic, :r2, :r2adj, :rmseout, :sse])
const LOGIT_EQUATION_GENERAL_INFORMATION = Vector{Symbol}([:nobs, :ncoef, :r2, :LR, :rmse, :r2adj, :sse])
const LOGIT_CRITERIA_DEFAULT = Vector{Symbol}([:r2adj])

const SUMMARY_VARIABLES = Dict(
    :nobs => Dict("verbose_title" => "Observations", "verbose_show" => true, "order" => 1),
    :F => Dict("verbose_title" => "F-statistic", "verbose_show" => true, "order" => 2),
    :LR => Dict("verbose_title" => "Likelihood ratio test", "verbose_show" => true, "order" => 2),
)
