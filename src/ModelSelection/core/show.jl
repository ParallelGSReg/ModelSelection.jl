function Base.show(io::IO, data::ModelSelectionData; kwargs...)
    outputstr = ""
    for result in data.results
        if typeof(result) == ModelSelection.CrossValidation.CrossValidationResult
            outputstr = outputstr * ModelSelection.CrossValidation.to_string(data, result)
        elseif typeof(result) ==
               ModelSelection.AllSubsetRegression.AllSubsetRegressionResult
            outputstr =
                outputstr * ModelSelection.AllSubsetRegression.to_string(data, result)
        end
    end
    println(io, outputstr)
    return nothing
end

# TODO: Base.show(io::IO, data::ModelSelectionData; kwargs...) = show(io, data, kwargs)
