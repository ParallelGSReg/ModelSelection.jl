function to_string(data::ModelSelectionData)
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
    return outputstr
end
