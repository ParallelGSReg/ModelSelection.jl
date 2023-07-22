struct NumFolds
    num::Int64
end

function leave_one_fold_out(n::Int, i::Int)
    @assert 1 <= i <= n
    x = Array{Int}(undef, n - 1)
    for j = 1:i-1
        x[j] = j
    end
    for j = i+1:n
        x[j-1] = j
    end
    return x
end

function Base.iterate(numfolds::NumFolds, state::Int64 = 1)
    if numfolds.num < state
        return nothing
    end
    return leave_one_fold_out(numfolds.num, state), state + 1
end

length(numfolds::NumFolds) = numfolds.num

function split_database(database::Array{Int,1}, numfolds::Int)
    n = size(database, 1)
    [database[(i-1)*(ceil(Int, n / numfolds))+1:min(i * (ceil(Int, n / numfolds)), n)] for i = 1:numfolds]
end

function kfoldcrossvalidation!(
    data::ModelSelection.ModelSelectionData,
    original_data::ModelSelection.ModelSelectionData,
    numfolds::Int;
    notify = nothing,
)
    validate_panel_time(data)
    validate_numfolds(data, numfolds)
    
    obs_array = collect(1:original_data.nobs)
    folds = split_database(obs_array, numfolds)

    progress = 0
    total_step_porcentage = 70
    step = floor(Int64, total_step_porcentage / numfolds)
    notification(notify, NOTIFY_MESSAGE, progress=progress)
    asr_result = ModelSelection.getresult(data, ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)

    bestmodels = []
    cont = 1
    for obs in NumFolds(numfolds)
        dataset = collect(Iterators.flatten(folds[obs]))
        testset = setdiff(1:original_data.nobs, dataset)
        
        model_data = ModelSelection.copy_modelselectiondata(original_data)
        
        if haskey(data.extras, ModelSelection.PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)
            reduced = ModelSelection.copy_modelselectiondata(original_data)
            reduced.depvar_data = original_data.depvar_data[dataset]
            reduced.expvars_data = original_data.expvars_data[dataset, :]
            if reduced.fixedvariables !== nothing
                reduced.fixedvariables_data = original_data.fixedvariables_data[dataset, :]
            end 
            reduced.nobs = size(dataset, 1)
            
            preliminary_selection = data.extras[ModelSelection.PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY]
            ModelSelection.PreliminarySelection.preliminary_selection!(preliminary_selection[:preliminaryselection], reduced)

            vars = reduced.extras[ModelSelection.PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY][:vars]
            model_data.expvars = data.expvars[vars]
            model_data.expvars_data = data.expvars_data[:, vars]
        end

        estimator = asr_result.estimator
        if estimator == :ols
            criteria = :rmseout
            ttest = asr_result.ttest
            ztest = false
        elseif estimator == :logit
            criteria = :rmseout
            ttest = false
            ztest = asr_result.ztest
        end
        residualtest = asr_result.residualtest
        method = asr_result.method
        model_result = ModelSelection.AllSubsetRegression.all_subset_regression!(
            estimator,
            model_data,
            method = method,
            outsample = testset,
            criteria = criteria,
            ttest = ttest,
            ztest = ztest,
            residualtest = residualtest,
        )
        ModelSelection.save_csv("result_"*string(cont)*".csv", model_data)
        cont = cont + 1
        push!(
            bestmodels,
            Dict(
                :data => model_result.bestresult_data,
                :datanames => model_result.datanames,
            ),
        )
        progress = progress + step
        notification(notify, NOTIFY_MESSAGE, progress=progress)
    end

    notification(notify, NOTIFY_MESSAGE, progress=progress)

    datanames = unique(Iterators.flatten(model[:datanames] for model in bestmodels))
    crossvalidation_data = Array{Any,2}(zeros(size(bestmodels, 1), size(datanames, 1)))

    for (i, model) in enumerate(bestmodels)
        for (f, col) in enumerate(model[:datanames])
            pos = ModelSelection.get_column_index(col, datanames)
            crossvalidation_data[i, pos] = model[:data][f]
        end
    end
    replace!(crossvalidation_data, NaN => 0)

    average_data = mean(crossvalidation_data, dims = 1)
    median_data = median(crossvalidation_data, dims = 1)
    datanames_index = ModelSelection.create_datanames_index(datanames)

    result = CrossValidationResult(
        numfolds,
        asr_result.ttest,
        asr_result.ztest,
        datanames,
        average_data,
        median_data,
        crossvalidation_data,
    )

    result.average_data[datanames_index[:nobs]] = Int64(round(result.average_data[datanames_index[:nobs]]))
    result.median_data[datanames_index[:nobs]] = Int64(round(result.median_data[datanames_index[:nobs]]))

    data = ModelSelection.addresult!(data, result)
    ModelSelection.addresult!(data, CROSSVALIDATION_EXTRAKEY, result)
    addextras!(data, result)
    notification(notify, NOTIFY_MESSAGE, progress=progress)
    return data
end


function to_string(data::ModelSelection.ModelSelectionData, result::CrossValidationResult)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    summary_variables = SUMMARY_VARIABLES
    if :r2adj in result.datanames
        summary_variables[:r2adj] = Dict("verbose_title" => "Adjusted R²", "verbose_show" => true)  # FIXME: Use the dictionary
    end

    out = ModelSelection.sprintf_header_block("Cross validation average results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block(
        "Selected covariates",
        datanames_index,
        data.expvars,
        data,
        result,
        result.average_data,
    )
    out *= ModelSelection.sprintf_summary_block(
        datanames_index,
        result,
        result.average_data,
        summary_variables = summary_variables,
    )

    out *= ModelSelection.sprintf_newline(1)
    out *= ModelSelection.sprintf_header_block("Cross validation median results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block(
        "Covariates",
        datanames_index,
        data.expvars,
        data,
        result,
        result.median_data,
    )
    out *= ModelSelection.sprintf_summary_block(
        datanames_index,
        result,
        result.median_data,
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
function to_dict(data::ModelSelection.ModelSelectionData, result::CrossValidationResult)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    expvars = ModelSelection.get_selected_variables_varnames(1, data.expvars, false)

    summary = Dict{Symbol,Any}()

    summary[:average] = Dict{Symbol,Any}()
    summary[:average] = ModelSelection.add_depvar(summary[:average], data.depvar)
    summary[:average] = ModelSelection.add_best_covars(
        summary[:average],
        :expvars,
        datanames_index,
        expvars,
        result,
        result.average_data,
    )
    summary[:average][:fixedvariables] = nothing
    if data.fixedvariables !== nothing
        summary[:average] = ModelSelection.add_best_covars(
            summary[:average],
            :fixedvariables,
            datanames_index,
            data.fixedvariables,
            result,
            result.average_data,
        )
    end
    summary[:average] = ModelSelection.add_summary_stats(
        summary[:average],
        datanames_index,
        result.average_data,
        summary_variables = SUMMARY_VARIABLES,
    )

    summary[:median] = Dict{Symbol,Any}()
    summary[:median] = ModelSelection.add_depvar(summary[:median], data.depvar)
    summary[:median] = ModelSelection.add_best_covars(
        summary[:median],
        :expvars,
        datanames_index,
        data.expvars,
        result,
        result.median_data,
    )
    summary[:median][:fixedvariables] = nothing
    if data.fixedvariables !== nothing
        summary[:median] = ModelSelection.add_best_covars(
            summary[:median],
            :fixedvariables,
            datanames_index,
            data.fixedvariables,
            result,
            result.median_data,
        )
    end
    summary[:median] = ModelSelection.add_summary_stats(
        summary[:median],
        datanames_index,
        result.median_data,
        summary_variables = SUMMARY_VARIABLES,
    )
    return summary
end
