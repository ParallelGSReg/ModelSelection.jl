"""
Returns if a vector is inside another vector.
# Arguments
- `sub_vector::Vector`: vector to match inside another vector.
- `vector::Vector`: vector that could contains the other vector.
"""
function in_vector(sub_vector::Vector, vector::Vector)
    for sv in sub_vector
        if !in(sv, vector)
            return false
        end
    end
    return true
end


"""
Generate extra name adding a posfix to a name is not exists.
# Arguments
- `extra_name::Symbol`: the name to be added a posfix.
- `extras::Dict{Symbol,Any}`: the dictionary of extras.
"""
function generate_extra_key(extra_key::Symbol, extras::Dict{Symbol,Any})
    if !(extra_key in keys(extras))
        return extra_key
    end
    posfix = 2
    while Symbol(string(extra_key, "_", posfix)) in keys(extras)
        posfix = posfix + 1
    end
    return Symbol(string(extra_key, "_", posfix))
end

"""
Add ModelSelectionResult to a ModelSelectionData.
# Arguments
- `data::ModelSelectionData`: the ModelSelectionData to be added the result.
- `result::ModelSelectionResult`: the ModelSelectionResult to be added.
"""
function addresult!(data::ModelSelectionData, result::ModelSelectionResult)
    push!(data.results, result)
    return data
end


"""
Creates an array with datanames and positions
# Arguments
- `datanames::Vector{Symbol}`: the datanames.
"""
function create_datanames_index(datanames::Vector{Symbol})
    header = Dict{Symbol,Int64}()
    for (index, name) in enumerate(datanames)
        header[name] = index
    end
    return header
end


"""
Add intercept to ModelSelectionData expvars and expvars_data.
# Arguments
- `data::ModelSelectionData`: the ModelSelectionData to be added the intercept.
"""
function add_intercept!(data::ModelSelectionData)
    data.expvars_data = hcat(data.expvars_data, ones(data.nobs))
    push!(data.expvars, :_cons)
    return data
end


"""
Remove intercept from ModelSelectionData expvars and expvars_data.
# Arguments
- `data::ModelSelectionData`: the ModelSelectionData to be removed the intercept.
"""
function remove_intercept!(data::ModelSelectionData)
    cons_index = get_column_index(:_cons, data.expvars)
    data.expvars_data =
        hcat(data.expvars_data[:, 1:cons_index-1], data.expvars_data[:, cons_index+1:end])
    data.expvars = vcat(data.expvars[1:cons_index-1], data.expvars[cons_index+1:end])
    return data
end


"""
Gets the position of a name in names vector.
# Arguments
- `name::Union{String, Symbol}`: the name to find.
- `names::Union{Vector{String}, Vector{Symbol}}`: an array of stings and/or symbols.
"""
function get_column_index(
    name::Union{String,Symbol,Nothing},
    names::Union{Vector{String},Vector{Symbol}},
)
    if name === nothing
        return nothing
    end
    return findfirst(isequal(name), names)
end


"""
Returns selected appropiate explanatory variables for each iteration.
# Arguments
- `order::Int64`: the order of the model.
- `datanames::Vector{Symbol}`: the datanames.
- `intercept::Bool`: if the model has intercept.
"""
function get_selected_variables(order::Int64, datanames::Vector{Symbol}, intercept::Bool)
    cols = zeros(Int64, 0)
    binary = string(order, base = 2)
    k = 1
    for order = 1:length(binary)
        if binary[length(binary)-order+1] == '1'
            push!(cols, k)
        end
        k = k + 1
    end
    if intercept
        push!(cols, ModelSelection.get_column_index(:_cons, datanames))
    end
    return cols
end
