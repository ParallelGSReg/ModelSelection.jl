"""
Copies ModelSelectionData to new ModelSelectionData.
# Arguments
- `data::ModelSelectionData`: the ModelSelectionData to be copied.
"""
function copy_modelselectiondata(data::ModelSelectionData)
    new_data = ModelSelectionData(
        copy(data.equation),
        data.depvar,
        copy(data.expvars),
        data.fixedvariables !== nothing ? copy(data.fixedvariables) : nothing,
        data.time,
        data.panel,
        copy(data.depvar_data),
        copy(data.expvars_data),
        data.fixedvariables_data !== nothing ? copy(data.fixedvariables_data) : nothing,
        data.time_data !== nothing ? copy(data.time_data) : nothing,
        data.panel_data !== nothing ? copy(data.panel_data) : nothing,
        data.intercept,
        data.datatype,
        data.method,
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
