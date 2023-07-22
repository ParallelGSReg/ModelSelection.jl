"""
    parse_fe_variables(
        fe_vars::Union{Symbol,Vector{Symbol},Dict{Symbol,Int64},Vector{Tuple{Symbol, Symbol}}},
        expvars::Vector{Symbol};
        depvar::Union{Symbol,Nothing} = nothing,
    )

This function parses the fixed effect variables specified in `fe_vars` and returns them as a vector of symbols. It supports different input formats, including single symbols, vectors of symbols, dictionaries with symbols as keys and integers as values, or vectors of tuples with two symbols representing variable combinations. The function also checks the validity of the parsed variables based on the provided `expvars` (explanatory variables) and `depvar` (dependent variable).
If the parsed variables are empty or not found in the `expvars` list, the function returns `nothing`.

# Parameters
- `fe_vars::Union{Symbol, Vector{Symbol}, Dict{Symbol, Int64}, Vector{Tuple{Symbol,Symbol}}}`: Fixed effect variables specified as a symbol, vector of symbols, dictionary with symbols as keys and integers as values, or vector of tuples with two symbols.
- `expvars::Vector{Symbol}`: Vector of explanatory variables.
- `depvar::Union{Symbol, Nothing} = nothing`: Dependent variable symbol.

# Returns
- `Vector{Symbol}`: If `fe_vars` is a `Symbol` or a `Vector{Symbol}`, a vector of symbols representing the parsed fixed effects variables.
- `Dict{Symbol,Int64}`: If `fe_vars` is a `Dict{Symbol,Int64}`, a dict of symbols representing the parsed fixed effects variables with an int related with.
- `Vector{Tuple{Symbol,Symbol}}`: If `fe_vars` is a `Vector{Tuple{Symbol,Symbol}}`, a vector of tuple of symbols representing the parsed fixed effects variables tuples.
- `Nothing`: if `fe_vars` are not in `expvars` nor `depvar`.

# Example
```julia
expvars = [:x1, :x2, :x3]
fe_vars = [:x1, :x3]

vars = parse_fe_variables(fe_vars, expvars; depvar=:y)
# vars: [:x1, :x3]
```
```julia
expvars = [:x1, :x2, :x3]
fe_vars = Dict(:x1 => 1, :x3 => 2)

vars = parse_fe_variables(fe_vars, expvars; depvar=:y)
# vars: Dict(:x1 => 1, :x3 => 2)
```
```julia
expvars = [:x1, :x2, :x3]
fe_vars = [(:x1, :x2), (:x1, :x3)]

vars = parse_fe_variables(fe_vars, expvars; depvar=:y)
# vars: [(:x1, :x2), (:x1, :x3)]
```
"""
function parse_fe_variables(
    fe_vars::Union{Symbol,Vector{Symbol},Dict{Symbol,Int64},Vector{Tuple{Symbol,Symbol}}},
    expvars::Vector{Symbol};
    depvar::Union{Symbol,Nothing} = nothing,
)
    valid_vars = copy(expvars)
    if depvar !== nothing
        push!(valid_vars, depvar)
    end
    selected_vars = []
    vars = []
    if isa(fe_vars, Dict)
        for (var, value) in fe_vars
            push!(selected_vars, var)
        end
        vars = Dict{Symbol,Int64}(fe_vars)
    elseif isa(fe_vars, Vector{Tuple{Symbol,Symbol}})
        selected_combs = []
        for (var1, var2) in fe_vars
            selected_comb = var1 < var2 ? string(var1, "_", var2) : string(var2, "_", var1)
            if selected_comb in selected_combs
                continue
            end
            push!(selected_combs, selected_comb)
            vars = Vector{Tuple{Symbol,Symbol}}(fe_vars)
            push!(selected_vars, var1)
            push!(selected_vars, var2)
        end
    else
        selected_vars = fe_vars
        if !isa(fe_vars, Vector)
            selected_vars = Vector{Symbol}([fe_vars])
        end
        vars = Vector{Symbol}(selected_vars)
    end
    if isempty(vars) || !ModelSelection.in_vector(selected_vars, valid_vars)
        return nothing
    end
    return vars
end

"""
    data_add_fe_vars!(
        data::ModelSelection.ModelSelectionData,
        fe_vars::Union{Symbol,Vector{Symbol},Dict{Symbol,Int64}},
        postfix::String,
        func,
    )

This function adds fixed effect variables to the `data` in a model selection object. The fixed effect variables can be specified as a symbol, a vector of symbols, or a dictionary with symbols as keys and integers as values. The `postfix` argument is a string that will be appended to the variable names, and `func` is a function that will be applied to the fixed effect variables.
If a fixed effect variable already exists in the `data.expvars`, the function will update the corresponding column in `data.expvars_data` using the `func`. Otherwise, the function will create a new column in `data.expvars_data` and append the variable with the postfix to `data.expvars`.

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `fe_vars::Union{Symbol, Vector{Symbol}, Dict{Symbol, Int64}}`: Fixed effect variables specified as a symbol, vector of symbols, or dictionary with symbols as keys and integers as values.
- `postfix::String`: Postfix string to append to the variable names.
- `func`: Function to apply to the fixed effect variables.

# Example
```julia
data = ModelSelectionData(...)

fe_vars = [:x2, :x3]
postfix = "_fe"
func(data) = log.(data)

data_add_fe_vars!(data, fe_vars, postfix, func)
```
"""
function data_add_fe_vars!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol},Dict{Symbol,Int64}},
    postfix::String,
    func,
)
    vars = []
    existing_vars = []
    for fe_var in fe_vars
        if !(Symbol(string(fe_var, postfix)) in data.expvars)
            push!(vars, fe_var)
        else
            push!(existing_vars, fe_var)
        end
    end
    if size(vars, 1) > 0
        expvars_data = data.expvars_data[
            :,
            [ModelSelection.get_column_index(var, data.expvars) for var in vars],
        ]
        data.expvars_data = hcat(data.expvars_data, func(expvars_data))
        data.expvars = vcat(data.expvars, [Symbol(string(var, postfix)) for var in vars])
    end
    if size(existing_vars, 1) > 0
        expvars_data = data.expvars_data[
            :,
            [ModelSelection.get_column_index(var, data.expvars) for var in existing_vars],
        ]
        data.expvars_data[
            :,
            [
                ModelSelection.get_column_index(Symbol(string(var, postfix)), data.expvars)
                for var in existing_vars
            ],
        ] = func(expvars_data)
    end
end

"""
    data_add_fe_sqr!(
        data::ModelSelection.ModelSelectionData,
        fe_vars::Union{Symbol,Vector{Symbol}},
    )

Add squared fixed effect variables to the data in a model selection object.
The fixed effect variables can be specified as a symbol or a vector of symbols.
The function applies a square transformation to the fixed effect variables and appends them to `data.expvars` with the postfix "_sqrt".

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `fe_vars::Union{Symbol, Vector{Symbol}}`: Fixed effect variables specified as a symbol or vector of symbols.

# Example
```julia
data = ModelSelectionData(...)

fe_vars = [:x1, :x2]
data_add_fe_sqr!(data, fe_vars)
```
"""
function data_add_fe_sqr!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol}},
)
    postfix = "_sqrt"
    func(data) = data .^ 2
    data_add_fe_vars!(data, fe_vars, postfix, func)
end

"""
    data_add_fe_log!(
        data::ModelSelection.ModelSelectionData,
        fe_vars::Union{Symbol,Vector{Symbol}},
    )

Add logarithmic transformation of fixed effect variables to the data in a model selection object.
The fixed effect variables can be specified as a symbol or a vector of symbols.
The function applies a logarithmic transformation (`log.`) to the fixed effect variables and appends them to `data.expvars` with the postfix "_log".

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `fe_vars::Union{Symbol, Vector{Symbol}}`: Fixed effect variables specified as a symbol or vector of symbols.

# Errors
- `ArgumentError(LOG_FUNCTION_ERROR)`: When negative values are provided.

# Example
```julia
data = ModelSelectionData(...)

fe_vars = [:x1, :x2]
data_add_fe_log!(data, fe_vars)
```
"""
function data_add_fe_log!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol}},
)
    try
        postfix = "_log"
        func(data) = log.(data)
        data_add_fe_vars!(data, fe_vars, postfix, func)
    catch
        throw(ArgumentError(LOG_FUNCTION_ERROR))
    end
end

"""
    data_add_fe_inv!(
        data::ModelSelection.ModelSelectionData,
        fe_vars::Union{Symbol,Vector{Symbol}},
    )

Add inverse transformation of fixed effect variables to the data in a model selection object.
The fixed effect variables can be specified as a symbol or a vector of symbols.
The function applies an inverse transformation (`1 ./ data`) to the fixed effect variables and appends them to `data.expvars` with the postfix "_inv".

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `fe_vars::Union{Symbol, Vector{Symbol}}`: Fixed effect variables specified as a symbol or vector of symbols.

# Example
```julia
data = ModelSelectionData(...)

fe_vars = [:x1, :x2]
data_add_fe_inv!(data, fe_vars)
```
"""
function data_add_fe_inv!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol}},
)
    postfix = "_inv"
    func(data) = 1 ./ data
    data_add_fe_vars!(data, fe_vars, postfix, func)
end

"""
    data_add_fe_lag!(
        data::ModelSelection.ModelSelectionData,
        fe_vars::Dict{Symbol,Int64},
    )

Add lagged variables of fixed effect variables to the data in a model selection object.
The function iterates over the fixed effect variables in `fe_vars` and generates the lagged variables for each variable based on the specified number of lags.
The lagged variables are appended to `data.expvars` with the postfix "_lag" and added to `data.expvars_data` as new columns.
The lagged variables are computed for each unique value in `data.panel_data` if panel data is available. 
If a fixed effect variable is already present in `data.expvars`, the lagged values are overwritten in `data.expvars_data`.
If a fixed effect variable is not present in `data.expvars`, the lagged values are stored in a separate matrix `var_data` and later appended to `data.expvars_data`.

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `fe_vars::Dict{Symbol, Int64}`: Fixed effect variables and the number of lags specified as a dictionary.

# Example
```julia
data = ModelSelectionData(...)

fe_vars = Dict(:x1 => 1, :x2 => 2)
data_add_fe_lag!(data, fe_vars)
```
"""
function data_add_fe_lag!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Dict{Symbol,Int64},
)
    nobs = size(data.expvars_data, 1)
    postfix = "_lag"
    csis = (data.panel !== nothing) ? unique(data.panel_data) : [nothing]

    for (var, num) in fe_vars
        num_cols = 0
        for i = 1:num
            if !(Symbol(string(var, postfix, i)) in data.expvars)
                num_cols = num_cols + 1
            end
        end
        var_data = Array{Union{Missing,data.datatype}}(missing, nobs, num_cols)
        m = 1
        if var in data.expvars
            i_data = data.expvars_data
            col = ModelSelection.get_column_index(var, data.expvars)
        else
            i_data = data.depvar_data
            col = nothing
        end

        for i = 1:num
            expvar = Symbol(string(var, postfix, i))
            col_added = false
            for csi in csis
                rows =
                    (csi !== nothing) ? findall(x -> x == csi, data.panel_data) :
                    collect(1:1:nobs)
                num_rows = size(rows, 1)
                if col !== nothing
                    lag_data = lag(i_data[rows[1]:rows[1]+num_rows-1, col], i)
                else
                    lag_data = lag(i_data[rows[1]:rows[1]+num_rows-1], i)
                end
                if !(expvar in data.expvars)
                    var_data[rows[1]:rows[1]+num_rows-1, m] .= lag_data
                    col_added = true
                else
                    n = ModelSelection.get_column_index(expvar, data.expvars)
                    data.expvars_data[rows[1]:rows[1]+num_rows-1, n] .= lag_data
                end
            end
            if col_added
                m = m + 1
            end
            if !(expvar in data.expvars)
                data.expvars = vcat(data.expvars, [expvar])
            end
        end
        if size(var_data, 2) > 0
            data.expvars_data = hcat(data.expvars_data, var_data)
        end
    end
end

"""
    data_add_interaction!(
        data::ModelSelection.ModelSelectionData,
        interaction::Vector{Tuple{Symbol,Symbol}},
    )

Add interaction variables to the data in a model selection object.
The interaction variables are formed by multiplying the values of the specified variables in each tuple.
The function applies a logarithmic transformation (`log.`) to the fixed effect variables and appends them to `data.expvars` with the postfix "_log".

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `interaction::Vector{Tuple{Symbol, Symbol}}`: Vector of tuples representing the variables for interaction.

# Example
```julia
data = ModelSelectionData(...)

interaction = [(:x1, :x2), (:x1, :x3)]
data_add_interaction!(data, interaction)
```
"""
function data_add_interaction!(
    data::ModelSelection.ModelSelectionData,
    interaction::Vector{Tuple{Symbol,Symbol}},
)
    infix = "_"
    for (var1, var2) in interaction
        col = Symbol(string(var1, infix, var2))
        var1_data =
            data.expvars_data[:, ModelSelection.get_column_index(var1, data.expvars)]
        var2_data =
            data.expvars_data[:, ModelSelection.get_column_index(var2, data.expvars)]

        res = var1_data .* var2_data
        if !(col in data.expvars)
            data.expvars_data = hcat(data.expvars_data, res)
            push!(data.expvars, col)
        else
            data.expvars_data[:, ModelSelection.get_column_index(col, data.expvars)] = res
        end
    end
end

"""
addextras!(
    data::ModelSelection.ModelSelectionData,
    fe_sqr::Union{Vector{Symbol},Nothing} = nothing,
    fe_log::Union{Vector{Symbol},Nothing} = nothing,
    fe_inv::Union{Vector{Symbol},Nothing} = nothing,
    fe_lag::Union{Dict{Symbol,Int64}} = nothing,
    interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
    removemissings::Bool = false,
)

Adds extra information to the ModelSelectionData object.
The function modifies the `data` object in-place and returns the modified object.
    
# Parameters
- `fe_sqr::Union{Vector{Symbol}, Nothing}`: (optional) Vector of variables to be squared.
- `fe_log::Union{Vector{Symbol}, Nothing}`: (optional) Vector of variables to be transformed with the natural logarithm.
- `fe_inv::Union{Vector{Symbol}, Nothing}`: (optional) Vector of variables to be inverted (1/x).
- `fe_lag::Union{Dict{Symbol, Int64}, Nothing}`: (optional) Dictionary specifying the variables and their lag order.
- `interaction::Union{Vector{Tuple{Symbol, Symbol}}, Nothing}`: (optional) Vector of tuples representing variables for interaction.
- `removemissings::Bool`: (optional) Indicator whether to remove missing values from the data.

# Returns
- `data::ModelSelection.ModelSelectionData`: Model selection data object with updated data.

# Example
!!! warning
    TODO: Pending example.
"""
function addextras!(
    data::ModelSelection.ModelSelectionData,
    fe_sqr = nothing,
    fe_log = nothing,
    fe_inv = nothing,
    fe_lag = nothing,
    interaction = nothing,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    data.extras[ModelSelection.generate_extra_key(
        FEATUREEXTRACTION_EXTRAKEY,
        data.extras,
    )] = Dict(
        :fe_sqr => fe_sqr,
        :fe_log => fe_log,
        :fe_inv => fe_inv,
        :fe_lag => fe_lag,
        :interaction => interaction,
        :removemissings => removemissings,
    )
    return data
end
