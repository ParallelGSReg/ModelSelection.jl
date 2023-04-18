"""
Converts variables data to the appropriate data type.
# Arguments
- `datatype::Type`: datatype to convert.
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: variables data to be converted.
"""
function convert_variables_data(
    datatype::Type,
    data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Nothing,
    } = nothing,
)
    if data === nothing
        return nothing
    end
    has_missings = false
    if size(data, 2) == 1
        has_missings |= findfirst(x -> ismissing(x), data) !== nothing
    else
        for i in axes(data, 2)
            has_missings |= findfirst(x -> ismissing(x), data[:, i]) !== nothing
        end
    end
    if has_missings
        return Array{Union{Missing,datatype}}(data)
    end
    return Array{datatype}(data)
end


"""
Converts raw data to the appropriate data type.
# Arguments
- `datatype::Type`: the datatype.
- `depvar_data::Union{Vector{Float32}, Vector{Float64}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}}`: dependent variable data.
- `expvars_data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: explanatory variables data.
- `fixedvariables::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: fixed variables data.
- `time_data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: time variable data.
- `panel_data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: panel variable data.
"""
function convert_raw_data(
    datatype::Type,
    depvar_data::Union{
        Vector{Float32},
        Vector{Float64},
        Vector{Union{Float32,Missing}},
        Vector{Union{Float64,Missing}},
    },
    expvars_data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    fixedvariables_data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Nothing,
    } = nothing,
    time_data::Union{
        Vector{Float32},
        Vector{Float64},
        Array{Union{Float32,Missing}},
        Vector{Union{Float64,Missing}},
        Nothing,
    } = nothing,
    panel_data::Union{
        Vector{Float32},
        Vector{Float64},
        Vector{Union{Float32,Missing}},
        Vector{Union{Float64,Missing}},
        Nothing,
    } = nothing,
)
    depvar_data = convert_variables_data(datatype, depvar_data)
    expvars_data = convert_variables_data(datatype, expvars_data)
    fixedvariables_data = convert_variables_data(datatype, fixedvariables_data)
    time_data = convert_variables_data(datatype, time_data)
    panel_data = convert_variables_data(datatype == Float64 ? Int64 : Int32, panel_data)
    return depvar_data, expvars_data, fixedvariables_data, time_data, panel_data
end


"""
Converts ModelSelectionData data to the appropriate data type.
# Arguments
- `data::ModelSelectionData`: the data to be converted.
"""
function convert_data!(data::ModelSelectionData)
    depvar_data, expvars_data, time_data, panel_data = convert_raw_data(
        data.datatype,
        data.depvar_data,
        data.expvars_data,
        data.time_data,
        data.panel_data,
    )
    data.depvar_data = depvar_data
    data.expvars_data = expvars_data
    data.panel_data = panel_data
    data.time_data = time_data
    return data
end
