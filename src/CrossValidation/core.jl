abstract type CrossValGenerator end

struct LOOCV <: CrossValGenerator
    n::Int64
end

length(c::LOOCV) = c.n

function iterate(c::LOOCV, s::Int = 1)
    (s > c.n) && return nothing
    return (leave_one_out(c.n, s), s + 1)
end

function leave_one_out(n::Int, i::Int)
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

function split_database(database::Array{Int,1}, k::Int)
    n = size(database, 1)
    [database[(i-1)*(ceil(Int, n / k))+1:min(i * (ceil(Int, n / k)), n)] for i = 1:k]
end

function kfoldcrossvalidation!(
    previousresult::ModelSelection.ModelSelectionData,
    data::ModelSelection.ModelSelectionData,
    k::Int,
    s::Float64;
    notify = nothing,
)
    kfoldcrossvalidation(previousresult, data, k, s; notify = notify )
end


function kfoldcrossvalidation(
    previousresult::ModelSelection.ModelSelectionData,
    data::ModelSelection.ModelSelectionData,
    k::Int,
    s::Float64;
    notify = nothing,
)
    ModelSelection.notification(notify, "Performing Cross validation", Dict(:progress => 0))
    db = collect(1:data.nobs)
    folds = split_database(db, k)

    progress = 0
    step = floor(Int64, 50 / k)
    ModelSelection.notification(notify, "Performing Cross validation", Dict(:progress => progress))
    
    bestmodels = []
    for obs in LOOCV(k)
        testset = collect(Iterators.flatten(folds[obs]))
        dataset = setdiff(1:data.nobs, testset)

        reduced = ModelSelection.copy_modelselectiondata(data)
        reduced.depvar_data = data.depvar_data[dataset]
        reduced.expvars_data = data.expvars_data[dataset, :]
        if reduced.fixedvariables !== nothing
            reduced.fixedvariables_data = data.fixedvariables_data[dataset, :]
        end 
        reduced.nobs = size(dataset, 1)

        if haskey(data.extras, ModelSelection.PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)
            preliminary_selection = ModelSelection.PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY
            ModelSelection.PreliminarySelection.preliminary_selection!(preliminary_selection[:preliminaryselection], reduced)
        end

        estimator = previousresult.results[1].estimator
        if estimator == :ols
            criteria = :rmseout
            ttest = previousresult.results[1].ttest
            ztest = false
        elseif estimator == :logit
            criteria = :rocout
            ttest = false
            ztest = previousresult.results[1].ztest
        end
        residualtest = previousresult.results[1].residualtest

        ModelSelection.AllSubsetRegression.all_subset_regression!(
            estimator,
            reduced,
            outsample = testset,
            criteria = criteria,
            ttest = ttest,
            ztest = ztest,
            residualtest = residualtest,
        )

        push!(
            bestmodels,
            Dict(
                :data => reduced.results[1].bestresult_data,
                :datanames => reduced.results[1].datanames,
            ),
        )
        progress = progress + step
        ModelSelection.notification(notify, "Performing Cross validation", Dict(:progress => progress))
    end

    ModelSelection.notification(notify, "Performing Cross validation", Dict(:progress => 50))

    datanames = unique(Iterators.flatten(model[:datanames] for model in bestmodels))

    data = Array{Any,2}(zeros(size(bestmodels, 1), size(datanames, 1)))

    for (i, model) in enumerate(bestmodels)
        for (f, col) in enumerate(model[:datanames])
            pos = ModelSelection.get_column_index(col, datanames)
            data[i, pos] = model[:data][f]
        end
    end

    replace!(data, NaN => 0)

    average_data = mean(data, dims = 1)
    median_data = median(data, dims = 1)

    datanames_index = ModelSelection.create_datanames_index(datanames)

    result = CrossValidationResult(
        k,
        0,
        reduced.results[1].ttest,
        reduced.results[1].ztest,
        datanames,
        average_data,
        median_data,
        data,
    )

    result.average_data[datanames_index[:nobs]] =
        Int64(round(result.average_data[datanames_index[:nobs]]))
    result.median_data[datanames_index[:nobs]] =
        Int64(round(result.median_data[datanames_index[:nobs]]))

    reduced = ModelSelection.addresult!(reduced, result)

    addextras!(reduced, result)
    ModelSelection.notification(notify, "Performing Cross validation", Dict(:progress => 100))

    return reduced
end

function to_string(data::ModelSelection.ModelSelectionData, result::CrossValidationResult)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    expvars = ModelSelection.get_selected_variables_varnames(1, data.expvars, false)
    out = ModelSelection.sprintf_header_block("Cross validation average results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block(
        "Selected covariates",
        datanames_index,
        expvars,
        data,
        result,
        result.average_data,
    )
    out *= ModelSelection.sprintf_summary_block(
        datanames_index,
        result,
        result.average_data,
        summary_variables = SUMMARY_VARIABLES,
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
        summary_variables = SUMMARY_VARIABLES,
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
