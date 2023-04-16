using DelimitedFiles

"""
Saves a csv file.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `filename::String``: output filename.
- `resultnum::Int64`: TODO add description.
"""
function save_csv(filename::String, data::ModelSelection.ModelSelectionData)
    for result in data.results
        save_csv(filename, result)
    end
end

"""
Exports to csv with all subset regression result.
# Arguments
- `filename::String: output filename.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
"""
function save_csv(
    filename::String,
    result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult,
)
    filename = replace(filename, ".csv" => "") * "_allsubsetregression.csv"
    export_csv(filename, result)
end

"""
Exports to csv with cross validation result.
# Arguments
- `filename::String: output filename.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
"""
function save_csv(
    filename::String,
    result::ModelSelection.CrossValidation.CrossValidationResult,
)
    filename = replace(filename, ".csv" => "") * "_crossvalidation.csv"
    export_csv(filename, result)
end

"""
Exports to csv for any result.
# Arguments
- `filename::String: output filename.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
"""
function export_csv(
    filename::String,
    result::Union{
        ModelSelection.AllSubsetRegression.AllSubsetRegressionResult,
        ModelSelection.CrossValidation.CrossValidationResult,
    },
)
    header = []
    for dataname in result.datanames
        push!(header, String(dataname))
    end
    rows = vcat(permutedims(header), result.data)
    if filename !== nothing
        file = open(filename, "w")
        writedlm(file, rows, ',')
        close(file)
    end
end
