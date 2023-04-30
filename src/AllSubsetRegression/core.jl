include("estimators/ols.jl")
include("estimators/logit.jl")


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
to_string
"""
function to_string(
    data::ModelSelectionData,
    result::AllSubsetRegressionResult,
)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    summary_variables = SUMMARY_VARIABLES
    if :r2adj in result.datanames
        summary_variables[:r2adj] = Dict("verbose_title" => "Adjusted R²", "verbose_show" => true)
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
    out *= ModelSelection.sprintf_covvars_block("Selected covariates", datanames_index, expvars, data, result, result.bestresult_data)
    out *= ModelSelection.sprintf_summary(datanames_index, result, result.bestresult_data, summary_variables=summary_variables, criteria_variables=criteria_variables)
    if !result.modelavg
        out *= ModelSelection.sprintf_simpleline(new_line = true)
        return out
    end
    out *= ModelSelection.sprintf_newline()
    out *= ModelSelection.sprintf_header_block("Model averaging results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block("Covariates", datanames_index, data.expvars, data, result, result.modelavg_data)
    summary_variables[:order] = Dict("verbose_title" => "Combined criteria", "verbose_show" => true)
    out *= ModelSelection.sprintf_summary(datanames_index, result, result.modelavg_data, summary_variables=summary_variables)
    out *= ModelSelection.sprintf_newline()
    return out
end
