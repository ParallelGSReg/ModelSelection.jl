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

const QR_64 = :qr_64
const QR_32 = :qr_32
const QR_16 = :qr_16
const CHO_64 = :cho_64
const CHO_32 = :cho_32
const CHO_16 = :cho_16
const SVD_64 = :svd_64
const SVD_32 = :svd_32
const SVD_16 = :svd_16
const METHODS_DATATYPES = Dict(
    QR_64 => Float64,
    QR_32 => Float32,
    QR_16 => Float16,
    CHO_64 => Float64,
    CHO_32 => Float32,
    CHO_16 => Float16,
    SVD_64 => Float64,
    SVD_32 => Float32,
    SVD_16 => Float16,
)

const CRITERIA = :criteria
const METHOD = :method
const AVAILABLE = :available
const DEFAULT = :default
const GENERAL_INFORMATION = :general_information
const SUMMARY_VARIABLES = :summary_variables

const LOGIT = :logit
const OLS = :ols
const ESTIMATORS_AVAILABLE = Vector{Symbol}([LOGIT, OLS])

const ESTIMATORS = Dict(
    OLS => Dict(
        CRITERIA => Dict(
            AVAILABLE => Vector{Symbol}([:aic, :aicc, :bic, :cp, :r2adj, :rmse, :rmseout, :sse]),
            DEFAULT => Vector{Symbol}([:r2adj]),
        ),
        METHOD => Dict(
            AVAILABLE => Vector{Symbol}([QR_64, QR_32, QR_16, CHO_64, CHO_32, CHO_16, SVD_64, SVD_32, SVD_16]),
            DEFAULT => QR_32,
        ),
        GENERAL_INFORMATION => Vector{Symbol}([:nobs, :ncoef, :r2, :F, :rmse, :r2adj, :sse]),
        SUMMARY_VARIABLES => Dict( # FIXME: Move to a general structure
            :nobs => Dict("verbose_title" => "Observations", "verbose_show" => true, "order" => 1),
            :F => Dict("verbose_title" => "F-statistic", "verbose_show" => true, "order" => 2),
        ),
    ),
    LOGIT => Dict(
        CRITERIA => Dict(
            AVAILABLE => Vector{Symbol}([:aic, :aicc, :bic, :r2adj, :rmseout, :sse]),
            DEFAULT => Vector{Symbol}([:r2adj]),
        ),
        METHOD => Dict(
            AVAILABLE => Vector{Symbol}([CHO_64, CHO_32, CHO_16]),
            DEFAULT => CHO_32,
        ),
        GENERAL_INFORMATION => Vector{Symbol}([:nobs, :ncoef, :r2, :LR, :rmse, :r2adj, :sse]),
        SUMMARY_VARIABLES => Dict( # FIXME: Move to a general structure
            :nobs => Dict("verbose_title" => "Observations", "verbose_show" => true, "order" => 1),
            :LR => Dict("verbose_title" => "Likelihood ratio test", "verbose_show" => true, "order" => 2),
        ),
    ),
)


