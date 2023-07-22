"""
Saves a csv file.
# Parameters
- `filename::String``: output filename.
- `data::ModelSelection.ModelSelectionData`: the model selection data.
"""
function save_csv(filename::String, data::ModelSelection.ModelSelectionData)
    for result in data.results
        save_csv(filename, data, result)
    end
end


"""
Exports to csv with all subset regression result.
# Parameters
- `filename::String: output filename.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
"""
function save_csv(
    filename::String,
    data::ModelSelection.ModelSelectionData,
    result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult,
)
    filename = replace(filename, ".csv" => "") * "_allsubsetregression.csv"
    export_csv(filename, data, result)
end


"""
Exports to csv with cross validation result.
# Parameters
- `filename::String: output filename.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
"""
function save_csv(
    filename::String,
    data::ModelSelection.ModelSelectionData,
    result::ModelSelection.CrossValidation.CrossValidationResult,
)
    filename = replace(filename, ".csv" => "") * "_crossvalidation.csv"
    export_csv(filename, data, result)
end

"""
Exports to csv for any result.
# Parameters
- `filename::String: output filename.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
"""
function export_csv(
    filename::String,
    data::ModelSelection.ModelSelectionData,
    result::Union{
        ModelSelection.AllSubsetRegression.AllSubsetRegressionResult,
        ModelSelection.CrossValidation.CrossValidationResult,
    },
)
    header = []

    index_index = nothing
    expvars = []
    expvars_indexes = []
    fixedvariables = []
    fixedvariables_indexes = []
    others = []
    others_indexes = []
    
    for (index, dataname) in enumerate(result.datanames)
        root_dataname = Symbol(split(string(dataname), "_")[1])
        if root_dataname === AllSubsetRegression.INDEX
            index_index = index
        elseif root_dataname in data.expvars
            push!(expvars, String(dataname))
            push!(expvars_indexes, index)
        elseif data.fixedvariables !== nothing && root_dataname in data.fixedvariables
            push!(fixedvariables, String(dataname))
            push!(fixedvariables_indexes, index)
        else
            push!(others, String(dataname))
            push!(others_indexes, index)
        end
    end

    data = nothing
    header = []
    if index_index !== nothing
        data = result.data[:, index_index]
        push!(header, AllSubsetRegression.INDEX)
    end
    if !isempty(fixedvariables_indexes)
        fixedvariables_data = result.data[:, fixedvariables_indexes]
        if data === nothing
            data = fixedvariables_data
        else 
            data = hcat(data, fixedvariables_data)
        end
        header = vcat(header, fixedvariables)
    end
    if !isempty(expvars_indexes)
        expvars_data = result.data[:, expvars_indexes]
        if data === nothing
            data = expvars_data
        else 
            data = hcat(data, expvars_data)
        end
        header = vcat(header, expvars)
    end
    data = hcat(data, result.data[:, others_indexes])
    header = vcat(header, others)

    rows = vcat(permutedims(header), data)
    if filename !== nothing
        file = open(filename, "w")
        replace!(rows, NaN => "")
        writedlm(file, rows, ',')
        close(file)
    end
end
