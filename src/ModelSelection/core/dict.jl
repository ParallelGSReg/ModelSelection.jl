function to_dict(data::ModelSelectionData; kwargs...)
    summary = Dict{Symbol,Any}()
    for result in data.results
        if typeof(result) == ModelSelection.CrossValidation.CrossValidationResult
            summary[:crossvalidation] = ModelSelection.CrossValidation.to_dict(data, result)
        elseif typeof(result) ==
               ModelSelection.AllSubsetRegression.AllSubsetRegressionResult
            summary[:allsubsetregression] =
                ModelSelection.AllSubsetRegression.to_dict(data, result)
        end
    end
    return summary
end
