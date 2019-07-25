#TODO: Refactor as summary

function csv(data::ModelSelection.ModelSelectionData, filename::String; resultnum::Int64=1)
    csv(data, filename=filename, resultnum=resultnum)
end

function csv(data::ModelSelection.ModelSelectionData; filename::Union{Nothing, String}=nothing, resultnum::Int64=1)
    addextras(data, :csv, filename, nothing)
    if size(data.results, 1) > 0
        return csv(data, data.results[resultnum], filename=filename)
    end
    return ""
end

function csv(data::ModelSelection.ModelSelectionData, result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult, filename::String)
    return csv(data, result, filename=filename)
end

function csv(data::ModelSelection.ModelSelectionData, result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult; filename::Union{Nothing, String}=nothing)
    header = []
    for dataname in result.datanames
        push!(header, String(dataname))
    end

    rows = vcat(permutedims(header), result.data)
    
    if filename != nothing
        file = open(filename, "w")
        writedlm(file, rows, ',')
        close(file)
    end

    res = ""    
    for row in eachrow(rows)
        res *= @sprintf("%s\n", join(row, ','))
    end
    return res
end


function csv(data::ModelSelection.ModelSelectionData, result::ModelSelection.CrossValidation.CrossValidationResult, filename::String)
    return csv(data, result, filename=filename)
end

function csv(data::ModelSelection.ModelSelectionData, result::ModelSelection.CrossValidation.CrossValidationResult; filename::Union{Nothing, String}=nothing)
    header = []
    for dataname in result.datanames
        push!(header, String(dataname))
    end

    rows = vcat(permutedims(header), result.data)
    
    if filename != nothing
        file = open(filename, "w")
        writedlm(file, rows, ',')
        close(file)
    end

    res = ""    
    for row in eachrow(rows)
        res *= @sprintf("%s\n", join(row, ','))
    end
    return res
end
