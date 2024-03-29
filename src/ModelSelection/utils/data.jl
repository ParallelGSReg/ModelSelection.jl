"""
Returns if a vector is inside another vector.
# Parameters
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
# Parameters
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
# Parameters
- `data::ModelSelectionData`: the ModelSelectionData to be added the result.
- `result::ModelSelectionResult`: the ModelSelectionResult to be added.
"""
function addresult!(data::ModelSelectionData, result::ModelSelectionResult)
    push!(data.results, result)
    return data
end

function addresult!(data::ModelSelectionData, key::Symbol, result::ModelSelectionResult)
    data.results_dict[key] = result
    return data
end

function getresult(data::ModelSelectionData, key::Symbol)
    if !haskey(data.results_dict, key)
        return nothing
    end
    return data.results_dict[key]
end

"""
Creates a dictionary that maps variable names to their corresponding column indices in the result_data array.

# Parameters
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
# Parameters
- `data::ModelSelectionData`: the ModelSelectionData to be added the intercept.
"""
function add_intercept!(data::ModelSelectionData)
    data.expvars_data = hcat(data.expvars_data, ones(data.nobs))
    push!(data.expvars, CONS)
    return data
end


"""
Remove intercept from ModelSelectionData expvars and expvars_data.
# Parameters
- `data::ModelSelectionData`: the ModelSelectionData to be removed the intercept.
"""
function remove_intercept!(data::ModelSelectionData)
    cons_index = get_column_index(CONS, data.expvars)
    data.expvars_data =
        hcat(data.expvars_data[:, 1:cons_index-1], data.expvars_data[:, cons_index+1:end])
    data.expvars = vcat(data.expvars[1:cons_index-1], data.expvars[cons_index+1:end])
    return data
end


"""
Gets the position of a name in names vector.
# Parameters
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
Returns selected appropiate explanatory variables for each iteration as col position.
# Parameters
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
        push!(cols, ModelSelection.get_column_index(CONS, datanames))
    end
    return cols
end

"""
Returns selected appropiate explanatory variables for each iteration as varnames.
# Parameters
- `order::Int64`: the order of the model.
- `datanames::Vector{Symbol}`: the datanames.
- `intercept::Bool`: if the model has intercept.
"""
function get_selected_variables_varnames(
    order::Int64,
    datanames::Vector{Symbol},
    intercept::Bool,
)
    cols = get_selected_variables(order, datanames, intercept)
    return datanames[cols]
end
