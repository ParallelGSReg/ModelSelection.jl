"""
    featureextraction!(
        data::ModelSelection.ModelSelectionData;
        fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
        fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
        fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
        fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
        interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
        removemissings::Bool = REMOVEMISSINGS_DEFAULT,
        notify = nothing,
    )

Perform feature extraction on the data in a model selection object.
It applies different feature extraction techniques to the specified variables and updates the data accordingly.

The available feature extraction options are:
- `fe_sqr`: Square the variables.
- `fe_log`: Apply the natural logarithm to the variables.
- `fe_inv`: Invert the variables (1/x).
- `fe_lag`: Lag the variables by a specified order.
- `interaction`: Create interaction variables from pairs of variables.
- `removemissings`: Indicator whether to remove missing values from the data.

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `fe_sqr::Union{Symbol, Vector{Symbol}, Nothing}`: (optional) Single symbol or vector of symbols representing variables to be squared.
- `fe_log::Union{Symbol, Vector{Symbol}, Nothing}`: (optional) Single symbol or vector of symbols representing variables to be transformed with the natural logarithm.
- `fe_inv::Union{Symbol, Vector{Symbol}, Nothing}`: (optional) Single symbol or vector of symbols representing variables to be inverted (1/x).
- `fe_lag::Union{Dict{Symbol, Int64}, Nothing}`: (optional) Dictionary specifying the variables and their lag order.
- `interaction::Union{Vector{Tuple{Symbol, Symbol}}, Nothing}`: (optional) Vector of tuples representing variables for interaction.
- `removemissings::Bool`: (optional) Indicator whether to remove missing values from the data.
- `notify`: (optional) Notification method. Default is `NOTIFY_DEFAULT`.

# Returns
- `data::ModelSelection.ModelSelectionData`: Model selection data object with updated data.

# Example
```julia
data = ModelSelection.ModelSelectionData(...)

featureextraction!(
    data,
    fe_sqr = :x1,
    fe_log = [:x2, :x3],
    fe_inv = :x4,
    fe_lag = Dict(:x5 => 1),
    interaction = [(x6, x7),
    removemissings = true,
]
```
"""
function featureextraction!(
    data::ModelSelection.ModelSelectionData;
    fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
    interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = nothing,
)
    data = execute!(
        data,
        fe_sqr = fe_sqr,
        fe_log = fe_log,
        fe_inv = fe_inv,
        fe_lag = fe_lag,
        interaction = interaction,
        removemissings = removemissings,
        notify = notify,
    )
    data = addextras!(data, fe_sqr, fe_log, fe_inv, fe_lag, interaction, removemissings)
    return data
end

"""
    execute!(
        data::ModelSelection.ModelSelectionData;
        fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
        fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
        fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
        fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
        interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
        removemissings::Bool = REMOVEMISSINGS_DEFAULT,
        notify = nothing,
    )
Execute feature extraction operations on the data in a model selection object.
It performs operations such as squaring variables, applying the natural logarithm, inverting variables, lagging variables, and creating interaction variables.

The available feature extraction options are:
- `fe_sqr`: Square the variables.
- `fe_log`: Apply the natural logarithm to the variables.
- `fe_inv`: Invert the variables (1/x).
- `fe_lag`: Lag the variables by a specified order.
- `interaction`: Create interaction variables from pairs of variables.
- `removemissings`: Indicator whether to remove missing values from the data.

# Parameters
- `data::ModelSelection.ModelSelectionData`: Model selection data object.
- `fe_sqr::Union{Symbol, Vector{Symbol}, Nothing}`: (optional) Single symbol or vector of symbols representing variables to be squared.
- `fe_log::Union{Symbol, Vector{Symbol}, Nothing}`: (optional) Single symbol or vector of symbols representing variables to be transformed with the natural logarithm.
- `fe_inv::Union{Symbol, Vector{Symbol}, Nothing}`: (optional) Single symbol or vector of symbols representing variables to be inverted (1/x).
- `fe_lag::Union{Dict{Symbol, Int64}, Nothing}`: (optional) Dictionary specifying the variables and their lag order.
- `interaction::Union{Vector{Tuple{Symbol, Symbol}}, Nothing}`: (optional) Vector of tuples representing variables for interaction.
- `removemissings::Bool`: (optional) Indicator whether to remove missing values from the data.
- `notify`: (optional) Notification method. Default is `NOTIFY_DEFAULT`.

# Returns
- `data::ModelSelection.ModelSelectionData`: Model selection data object with updated data.

# Example
```julia
data = ModelSelection.ModelSelectionData(...)

execute!(
    data,
    fe_sqr = :x1,
    fe_log = [:x2, :x3],
    fe_inv = :x4,
    fe_lag = Dict(:x5 => 1),
    interaction = [(x6, x7),
    removemissings = true,
]
```
"""
function execute!(
    data::ModelSelection.ModelSelectionData;
    fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
    interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = nothing,
)
    notification(notify, NOTIFY_MESSAGE, progress=0)

    if data.intercept
        ModelSelection.remove_intercept!(data)
    end

    if fe_sqr !== nothing
        vars = parse_fe_variables(fe_sqr, data.expvars)
        if vars === nothing
            throw(ArgumentError(SOME_VARIABLES_NOT_FOUND))
        end
        data_add_fe_sqr!(data, vars)
    end

    if fe_log !== nothing
        vars = parse_fe_variables(fe_log, data.expvars)
        if vars === nothing
            throw(ArgumentError(SOME_VARIABLES_NOT_FOUND))
        end
        data_add_fe_log!(data, vars)
    end

    if fe_inv !== nothing
        vars = parse_fe_variables(fe_inv, data.expvars)
        if vars === nothing
            throw(ArgumentError(SOME_VARIABLES_NOT_FOUND))
        end
        data_add_fe_inv!(data, vars)
    end

    if fe_lag !== nothing
        vars = parse_fe_variables(fe_lag, data.expvars, depvar = data.depvar)
        if vars === nothing
            throw(ArgumentError(SOME_VARIABLES_NOT_FOUND))
        end
        data_add_fe_lag!(data, vars)
    end

    if interaction !== nothing
        if data.depvar in [Symbol(item) for tuple in interaction for item in tuple]
            INTERACTION_DEPVAR_ERROR
        end
        if !ModelSelection.in_vector(
            [Symbol(item) for tuple in interaction for item in tuple],
            data.expvars,
        )
            throw(ArgumentError(INTERACTION_EQUATION_ERROR))
        end
        vars = parse_fe_variables(interaction, data.expvars)
        if vars === nothing
            throw(ArgumentError(SOME_VARIABLES_NOT_FOUND))
        end
        data_add_interaction!(data, vars)
    end

    if data.intercept
        ModelSelection.add_intercept!(data)
    end

    if removemissings
        data = ModelSelection.filter_data_by_empty_values!(data)
    end
    data = ModelSelection.convert_data!(data)

    notification(notify, NOTIFY_MESSAGE, progress=100)
    return data
end
