"""
Copies ModelSelectionData to new ModelSelectionData.
# Arguments
- `data::ModelSelectionData`: the ModelSelectionData to be copied.
"""
function copy_modelselectiondata(data::ModelSelectionData)
    fixedvariables = nothing
    if data.fixedvariables !== nothing
        fixedvariables = copy(data.fixedvariables)
    end
    fixedvariables_data = nothing
    if data.fixedvariables_data !== nothing
        fixedvariables_data = copy(data.fixedvariables_data)
    end
    time_data = nothing
    if data.time_data !== nothing
        time_data = copy(data.time_data)
    end
    panel_data = nothing
    if data.panel_data !== nothing
        panel_data = copy(data.panel_data)
    end
    new_data = ModelSelectionData(
        copy(data.equation),
        data.depvar,
        copy(data.expvars),
        fixedvariables,
        data.time,
        data.panel,
        copy(data.depvar_data),
        copy(data.expvars_data),
        fixedvariables_data,
        time_data,
        panel_data,
        data.intercept,
        data.datatype,
        data.removemissings,
        data.nobs,
    )
    new_data.extras = data.extras
    new_data.options = copy(data.options)
    new_data.results = copy(data.results) # TODO: Copy results objects
    if data.original_data !== nothing
        new_data.original_data = copy(data.original_data)
    end
    return new_data
end
