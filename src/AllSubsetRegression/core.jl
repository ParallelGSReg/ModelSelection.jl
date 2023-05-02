include("estimators/ols.jl")
include("estimators/logit.jl")

"""
    all_subset_regression(
        estimator::Symbol,
        data::ModelSelectionData;
        outsample::Union{Int,Array,Nothing} = OUTSAMPLE_DEFAULT,
        criteria::Vector{Symbol} = CRITERIA_DEFAULT,
        ttest::Bool = ZTEST_DEFAULT,
        ztest::Bool = ZTEST_DEFAULT,
        modelavg::Bool = MODELAVG_DEFAULT,
        residualtest::Bool = RESIDUALTEST_DEFAULT,
        orderresults::Bool = ORDERRESULTS_DEFAULT,
    ) -> ModelSelectionResult

Perform all-subset regression analysis using the specified estimator and options on the provided `ModelSelectionData`.

# Arguments
- `estimator::Symbol`: The estimator to be used for regression analysis. Supported values are `:ols` for Ordinary Least Squares and `:logit` for logistic regression.
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used in the model selection process.

# Keyword Arguments
- `outsample::Union{Int,Array,Nothing}`: The number of out-of-sample observations, an array of out-of-sample indices, or nothing. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: A vector of symbols representing the selection criteria to be used. Default: `CRITERIA_DEFAULT`.
- `ttest::Bool`: If `true`, perform t-tests for the coefficient estimates. Default: `ZTEST_DEFAULT`.
- `ztest::Bool`: If `true`, perform z-tests for the coefficient estimates. Default: `ZTEST_DEFAULT`.
- `modelavg::Bool`: If `true`, perform model averaging. Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform residual tests. Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results by the specified criteria. Default: `ORDERRESULTS_DEFAULT`.

# Returns
- `ModelSelectionResult`: An object containing the results of the all-subset regression analysis.

# Example
```julia
result = all_subset_regression(:ols, model_selection_data)
```
"""	
function all_subset_regression(
    estimator::Symbol,
    data::ModelSelectionData;
    outsample::Union{Int,Array,Nothing} = OUTSAMPLE_DEFAULT,
    criteria::Vector{Symbol} = CRITERIA_DEFAULT,
    ttest::Bool = ZTEST_DEFAULT,
    ztest::Bool = ZTEST_DEFAULT,
    modelavg::Bool = MODELAVG_DEFAULT,
    residualtest::Bool = RESIDUALTEST_DEFAULT,
    orderresults::Bool = ORDERRESULTS_DEFAULT,
)
    if ttest && ztest
        throw(ArgumentError(TTEST_ZTEST_BOTH_TRUE))
    end

    if estimator == :ols
        AllSubsetRegression.ols!(
            data,
            outsample = outsample,
            criteria = criteria,
            ttest = ttest,
            modelavg = modelavg,
            residualtest = residualtest,
            orderresults = orderresults,
        )
    elseif estimator == :logit
        AllSubsetRegression.logit!(
            data,
            outsample = outsample,
            criteria = criteria,
            ztest = ztest,
            modelavg = modelavg,
            residualtest = residualtest,
            orderresults = orderresults,
        )
    else
        throw(ArgumentError(INVALID_ESTIMATOR))
    end
end

"""
    to_string(
        data::ModelSelectionData,
        result::AllSubsetRegressionResult
    ) -> String

Generate a human-readable string representation of the best model results and model averaging results (if applicable) from the `AllSubsetRegressionResult` object.

# Arguments
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used in the model selection process.
- `result::AllSubsetRegressionResult`: The `AllSubsetRegressionResult` object containing the results of the all-subset regression analysis.

# Returns
- `String`: A formatted string representation of the best model results and model averaging results (if applicable).

# Example
```julia
result_string = to_string(model_selection_data, all_subset_regression_result)
```
"""
function to_string(data::ModelSelectionData, result::AllSubsetRegressionResult)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    summary_variables = SUMMARY_VARIABLES
    if :r2adj in result.datanames
        summary_variables[:r2adj] =
            Dict("verbose_title" => "Adjusted R²", "verbose_show" => true)
    end
    expvars = ModelSelection.get_selected_variables_varnames(
        Int64(result.bestresult_data[datanames_index[:index]]),
        data.expvars,
        false,
    )
    criteria_variables = Dict()
    for criteria in result.criteria
        criteria_variables[criteria] = AVAILABLE_CRITERIA[criteria]
    end

    out = ModelSelection.sprintf_header_block("Best model results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block(
        "Selected covariates",
        datanames_index,
        expvars,
        data,
        result,
        result.bestresult_data,
    )
    out *= ModelSelection.sprintf_summary_block(
        datanames_index,
        result,
        result.bestresult_data,
        summary_variables = summary_variables,
        criteria_variables = criteria_variables,
    )
    if !result.modelavg
        out *= ModelSelection.sprintf_simpleline(new_line = true)
        return out
    end
    out *= ModelSelection.sprintf_newline()
    out *= ModelSelection.sprintf_header_block("Model averaging results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block(
        "Covariates",
        datanames_index,
        data.expvars,
        data,
        result,
        result.modelavg_data,
    )
    summary_variables[:order] =
        Dict("verbose_title" => "Combined criteria", "verbose_show" => true)
    out *= ModelSelection.sprintf_summary_block(
        datanames_index,
        result,
        result.modelavg_data,
        summary_variables = summary_variables,
    )
    out *= ModelSelection.sprintf_newline()
    return out
end
