const ALLSUBSETREGRESSION_EXTRAKEY = :allsubsetregression
const CRITERIA_DEFAULT = []
const FIXEDVARIABLES_DEFAULT = nothing
const INSAMPLE_MIN = 20
const MODELAVG_DEFAULT = false
const ORDERRESULTS_DEFAULT = false
const OUTSAMPLE_DEFAULT = 20
const RESIDUALTEST_DEFAULT = false
const TTEST_DEFAULT = false

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
	),
	:aicc => Dict(
		"verbose_title" => "AIC Corrected",
		"verbose_show" => true,
		"index" => -1,
	),
	:bic => Dict(
		"verbose_title" => "BIC",
		"verbose_show" => true,
		"index" => -1,
	),
	:cp => Dict(
		"verbose_title" => "Mallows's Cp",
		"verbose_show" => true,
		"index" => -1,
	),
	:r2adj => Dict(
		"verbose_title" => "Adjusted R²",
		"verbose_show" => false,
		"index" => 1,
	),
	:rmse => Dict(
		"verbose_title" => "RMSE",
		"verbose_show" => true,
		"index" => -1,
	),
	:rmseout => Dict(
		"verbose_title" => "RMSE OUT",
		"verbose_show" => true,
		"index" => -1,
	),
	:sse => Dict(
		"verbose_title" => "SSE",
		"verbose_show" => true,
		"index" => -1,
	),
)
