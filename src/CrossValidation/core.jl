abstract type CrossValGenerator end

struct LOOCV <: CrossValGenerator
    n::Int
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
    s::Float64,
)
    kfoldcrossvalidation(previousresult, data, k, s)
end


function kfoldcrossvalidation(
    previousresult::ModelSelection.ModelSelectionData,
    data::ModelSelection.ModelSelectionData,
    k::Int,
    s::Float64,
)

    #db = randperm(data.nobs)
    db = collect(1:data.nobs)
    folds = split_database(db, k)

    # TODO: What this is commented?
    # if data.time != nothing
    #     if data.panel != nothing
    #         # time & panel -> vemos que pasa acá
    #         folds = []
    #     else
    #         # time -> divisiones sin permutación
    #         folds = []
    #     end
    # else
    #     folds = []
    # end

    bestmodels = []

    for obs in LOOCV(k)
        dataset = collect(Iterators.flatten(folds[obs]))
        testset = setdiff(1:data.nobs, dataset)

        reduced = ModelSelection.copy_modelselectiondata(data)
        reduced.depvar_data = data.depvar_data[dataset]
        reduced.expvars_data = data.expvars_data[dataset, :]

        if reduced.fixedvariables !== nothing
            reduced.fixedvariables_data = data.fixedvariables_data[dataset, :]
        end

        if reduced.time !== nothing
            reduced.time_data = data.time_data[dataset]
        end

        if reduced.panel !== nothing
            reduced.panel_data = data.panel_data[dataset]
        end

        reduced.nobs = size(dataset, 1)
        
        _, vars = ModelSelection.PreliminarySelection.lasso!(reduced, addextrasflag = false)

        backup = ModelSelection.copy_modelselectiondata(data)
        backup.expvars = data.expvars[vars]
        backup.expvars_data = data.expvars_data[:, vars]

        ModelSelection.AllSubsetRegression.ols!(
            backup,
            outsample = testset,
            criteria = [:rmseout],
            ttest = previousresult.results[1].ttest,
            residualtest = previousresult.results[1].residualtest,
        )

        push!(
            bestmodels,
            Dict(
                :data => backup.results[1].bestresult_data,
                :datanames => backup.results[1].datanames,
            ),
        )
    end

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
        previousresult.results[1].ttest,
        datanames,
        average_data,
        median_data,
        data,
    )

    result.average_data[datanames_index[:nobs]] = Int64(round(result.average_data[datanames_index[:nobs]]))
    result.median_data[datanames_index[:nobs]] = Int64(round(result.median_data[datanames_index[:nobs]]))

    previousresult = ModelSelection.addresult!(previousresult, result)

    addextras(previousresult, result)

    return previousresult
end

function to_string(data::ModelSelection.ModelSelectionData, result::CrossValidationResult)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    expvars = ModelSelection.get_selected_variables_varnames(1, data.expvars, false)
    out = ModelSelection.sprintf_header_block("Cross validation average results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block("Selected covariates", datanames_index, expvars, data, result, result.average_data)
    out *= ModelSelection.sprintf_summary_block(datanames_index, result, result.average_data, summary_variables=SUMMARY_VARIABLES)
    out *= ModelSelection.sprintf_newline(1)
    out *= ModelSelection.sprintf_header_block("Cross validation median results")
    out *= ModelSelection.sprintf_depvar_block(data)
    out *= ModelSelection.sprintf_covvars_block("Covariates", datanames_index, data.expvars, data, result, result.median_data)
    out *= ModelSelection.sprintf_summary_block(datanames_index, result, result.median_data, summary_variables=SUMMARY_VARIABLES)
    out *= ModelSelection.sprintf_newline()
    return out
end
