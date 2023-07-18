function validate_numfolds(data::ModelSelection.ModelSelectionData, numfolds::Int64)
    fullexpvars = data.expvars
    if data.fixedvariables !== nothing
        fullexpvars = vcat(fullexpvars, data.fixedvariables)
    end
    if data.nobs / numfolds < size(fullexpvars, 1)
        throw(ArgumentError(NUMFOLD_TO_LARGE))
    end
end

function validate_panel_time(data::ModelSelection.ModelSelectionData)
    if data.panel !== nothing || data.time !== nothing
        throw(ArgumentError(PANEL_TIME_NOT_SUPPORTED))
    end
end

"""
Add extra data to data
# Parameters
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelectionResult`: the model selection result.
"""
function addextras!(data, result)
    data.extras[ModelSelection.generate_extra_key(CROSSVALIDATION_EXTRAKEY, data.extras)] =
        Dict(
            :ttest => result.ttest,
            :ztest => result.ztest,
            :kfolds => result.k,
            :panel => data.panel,
            :time => data.time,
            :datanames => result.datanames,
            :median => result.median_data,
            :average => result.average_data,
        )
    return data
end

