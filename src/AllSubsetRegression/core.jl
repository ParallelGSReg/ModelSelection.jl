include("estimators/ols.jl")
include("estimators/logit.jl")

"""
    all_subset_regression!(
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

Perform all-subset regression analysis using the specified estimator and options on the
provided `ModelSelectionData`.

# Parameters
- `estimator::Symbol`: The estimator to be used for regression analysis. Supported values
   are `:ols` for Ordinary Least Squares and `:logit` for logistic regression.
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used
   in the model selection process.

# Keyword Arguments
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection. Default: `CRITERIA_DEFAULT`.
- `ttest::Union{Bool, Nothing}`: If `true`, perform t-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.
- `ztest::Union{Bool, Nothing}`: If `true`, perform z-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
   Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.
   Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results based on the selection criteria.
   Default: `ORDERRESULTS_DEFAULT`.

# Returns
- `ModelSelectionResult`: An object containing the results of the all-subset regression
   analysis.

# Example
```julia
result = all_subset_regression!(:ols, model_selection_data)
```
"""
function all_subset_regression!(
    estimator::Symbol,
    data::ModelSelectionData;
    outsample::Union{Int,Array,Nothing} = OUTSAMPLE_DEFAULT,
    criteria::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    ttest::Bool = ZTEST_DEFAULT,
    ztest::Bool = ZTEST_DEFAULT,
    modelavg::Bool = MODELAVG_DEFAULT,
    residualtest::Bool = RESIDUALTEST_DEFAULT,
    orderresults::Bool = ORDERRESULTS_DEFAULT,
    notify = nothing
)
    validate_test(ttest = ttest, ztest = ztest)
    if outsample === nothing
        outsample = OUTSAMPLE_DEFAULT
    end

    if estimator == :ols
        return AllSubsetRegression.ols!(
            data,
            outsample = outsample,
            criteria = criteria,
            ttest = ttest,
            modelavg = modelavg,
            residualtest = residualtest,
            orderresults = orderresults,
            notify = notify ,
        )
    elseif estimator == :logit
        return AllSubsetRegression.logit!(
            data,
            outsample = outsample,
            criteria = criteria,
            ztest = ztest,
            modelavg = modelavg,
            residualtest = residualtest,
            orderresults = orderresults,
            notify = notify ,
        )
    else
        throw(ArgumentError(INVALID_ESTIMATOR))
    end
end

"""
    to_string(
        data::ModelSelectionData,
        result::AllSubsetRegressionResult,
    ) -> String

Generate a human-readable string representation of the best model results and model
averaging results (if applicable) from the `AllSubsetRegressionResult` object.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used
   in the model selection process.
- `result::AllSubsetRegressionResult`: The `AllSubsetRegressionResult` object containing the
   results of the all-subset regression analysis.

# Returns
- `String`: A formatted string representation of the best model results and model averaging
   results (if applicable).

# Example
```julia
result_string = to_string(model_selection_data, all_subset_regression_result)
```
"""
function to_string(data::ModelSelectionData, result::AllSubsetRegressionResult)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)

    #MODIFICAMOS SUMMARY VARIABLES SEGUN ESTIMADOR
    summary_variables = (result.estimator = :logit ? SUMMARY_VARIABLES_LOGIT : SUMMARY_VARIABLES_OLS)
    if :r2adj in result.datanames
        summary_variables[:r2adj] = Dict("verbose_title" => "Adjusted R²", "verbose_show" => true)  # FIXME: Use the dictionary
    end
    expvars = ModelSelection.get_selected_variables_varnames(
        Int64(result.bestresult_data[datanames_index[:index]]), data.expvars, false,
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


"""
    to_dict(
        data::ModelSelectionData,
        result::AllSubsetRegressionResult,
    ) -> Dict{Symbol, Any}

Generate a dict representation of the best model results and model
averaging results (if applicable) from the `AllSubsetRegressionResult` object.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used
   in the model selection process.
- `result::AllSubsetRegressionResult`: The `AllSubsetRegressionResult` object containing the
   results of the all-subset regression analysis.

# Returns
- `Dict`: A formatted Dict representation of the best model results and model averaging
   results (if applicable).

# Example
```julia
result_string = to_dict(model_selection_data, all_subset_regression_result)
```
"""
function to_dict(data::ModelSelectionData, result::AllSubsetRegressionResult)
    #summary variables depend on estimator
    summary_variables = copy((result.estimator = :logit ? SUMMARY_VARIABLES_LOGIT : SUMMARY_VARIABLES_OLS))
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    best_results_expvars = ModelSelection.get_selected_variables_varnames(
        Int64(result.bestresult_data[datanames_index[:index]]),
        data.expvars,
        false,
    )
    criteria_variables = Dict()
    for criteria in result.criteria
        criteria_variables[criteria] = AVAILABLE_CRITERIA[criteria]
    end
    summary = Dict{Symbol,Any}()
    summary = ModelSelection.add_depvar(summary, data.depvar)
    summary = ModelSelection.add_best_covars(
        summary,
        :expvars,
        datanames_index,
        best_results_expvars,
        result,
        result.bestresult_data,
    )
    summary[:fixedvariables] = nothing
    if data.fixedvariables !== nothing
        summary = ModelSelection.add_best_covars(
            summary,
            :fixedvariables,
            datanames_index,
            data.fixedvariables,
            result,
            result.bestresult_data,
        )
    end
    summary = ModelSelection.add_summary_stats(
        summary,
        datanames_index,
        result.bestresult_data,
        summary_variables = summary_variables,
        criteria_variables = criteria_variables,
    )

    if !result.modelavg
        return summary
    end
    summary[:modelavg] = Dict{Symbol,Any}()
    summary[:modelavg] = ModelSelection.add_best_covars(
        summary[:modelavg],
        :expvars,
        datanames_index,
        data.expvars,
        result,
        result.modelavg_data,
    )
    summary[:modelavg][:fixedvariables] = nothing
    if data.fixedvariables !== nothing
        summary[:modelavg] = ModelSelection.add_best_covars(
            summary[:modelavg],
            :fixedvariables,
            datanames_index,
            data.fixedvariables,
            result,
            result.modelavg_data,
        )
    end
    summary[:modelavg] = ModelSelection.add_summary_stats(
        summary[:modelavg],
        datanames_index,
        result.modelavg_data,
        summary_variables = summary_variables,
        criteria_variables = criteria_variables,
    )

    return summary
end
