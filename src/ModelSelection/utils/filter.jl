"""
Filters raw data removing empty or missing values. TODO: Fixed datatypes in doc
# Parameters
- `datatype::Type`: the datatype.
- `depvar_data::Union{Vector{Float32}, Vector{Float64}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}}`: dependent variable data.
- `expvars_data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: explanatory variables data.
- `fixedvariables_data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: fixed variables data.
- `time_data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: time variable data.
- `panel_data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: panel variable data.
"""
function filter_raw_data_by_empty_values(
    datatype::Type,
    depvar_data::Union{
        Vector{Float64},
        Vector{Float32},
        Vector{Float16},
        Vector{Union{Float64,Missing}},
        Vector{Union{Float32,Missing}},
        Vector{Union{Float16,Missing}},
    },
    expvars_data::Union{
        Matrix{Float64},
        Matrix{Float32},
        Matrix{Float16},
        Matrix{Union{Float64,Missing}},
        Matrix{Union{Float32,Missing}},
        Matrix{Union{Float16,Missing}},
    },
    fixedvariables_data::Union{
        Matrix{Float64},
        Matrix{Float32},
        Matrix{Float16},
        Matrix{Union{Float64,Missing}},
        Matrix{Union{Float32,Missing}},
        Matrix{Union{Float16,Missing}},
        Nothing,
    } = nothing,
    time_data::Union{
        Vector{Float64},
        Vector{Float32},
        Vector{Float16},
        Vector{Union{Float64,Missing}},
        Vector{Union{Float32,Missing}},
        Vector{Union{Float16,Missing}},
        Vector{Int64},
        Vector{Int32},
        Vector{Int16},
        Vector{Union{Int64,Missing}},
        Vector{Union{Int32,Missing}},
        Vector{Union{Int16,Missing}},
        Nothing,
    } = nothing,
    panel_data::Union{
        Vector{Float64},
        Vector{Float32},
        Vector{Float16},
        Vector{Union{Float64,Missing}},
        Vector{Union{Float32,Missing}},
        Vector{Union{Float16,Missing}},
        Vector{Int64},
        Vector{Int32},
        Vector{Int16},
        Vector{Union{Int64,Missing}},
        Vector{Union{Int32,Missing}},
        Vector{Union{Int16,Missing}},
        Nothing,
    } = nothing,
)
    keep_rows = Array{Bool}(undef, size(depvar_data, 1))
    keep_rows .= true
    keep_rows .&= map(b -> !b, ismissing.(depvar_data))

    for i in axes(expvars_data, 2)
        keep_rows .&= map(b -> !b, ismissing.(expvars_data[:, i]))
    end
    if fixedvariables_data !== nothing
        for i in axes(fixedvariables_data, 2)
            keep_rows .&= map(b -> !b, ismissing.(fixedvariables_data[:, i]))
        end
    end
    depvar_data = convert(Array{datatype}, depvar_data[keep_rows, 1])
    expvars_data = convert(Array{datatype}, expvars_data[keep_rows, :])

    if fixedvariables_data !== nothing
        fixedvariables_data = convert(Array{datatype}, fixedvariables_data[keep_rows, :])
    end
    time_data = time_data !== nothing ? time_data = time_data[keep_rows, 1] : time_data
    panel_data = panel_data !== nothing ? panel_data = panel_data[keep_rows, 1] : panel_data

    return depvar_data, expvars_data, fixedvariables_data, time_data, panel_data
end


"""
Filters ModelSelectionData data removing empty or missing values.
# Parameters
- `data::ModelSelectionData`: the ModelSelectionData to be filtered.
"""
function filter_data_by_empty_values!(data::ModelSelectionData)
    depvar_data, expvars_data, fixedvariables_data, time_data, panel_data =
        filter_raw_data_by_empty_values(
            data.datatype,
            data.depvar_data,
            data.expvars_data,
            data.fixedvariables_data,
            data.time_data,
            data.panel_data,
        )

    data.depvar_data = depvar_data
    data.expvars_data = expvars_data
    data.fixedvariables_data = fixedvariables_data
    data.time_data = time_data
    data.panel_data = panel_data
    data.nobs = size(data.depvar_data, 1)
    data.removemissings = true
    return data
end
