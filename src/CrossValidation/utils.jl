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
            :tsetsize => result.s,
            :panel => data.panel,
            :time => data.time,
            :datanames => result.datanames,
            :median => result.median_data,
            :average => result.average_data,
        )
    return data
end
