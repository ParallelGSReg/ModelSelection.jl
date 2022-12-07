function featureextraction(
    data::ModelSelection.ModelSelectionData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array, Dict}=nothing,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    return featureextraction!(
        ModelSelection.copy_data(data),
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        interaction=interaction,
        removemissings=removemissings
    )
end

function featureextraction!(
    data::ModelSelection.ModelSelectionData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array, Dict}=nothing,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    data = execute!(
        data,
        fe_sqr=fe_sqr,
        fe_log=fe_log,
        fe_inv=fe_inv,
        fe_lag=fe_lag,
        interaction=interaction,
        removemissings=removemissings
    )

    data = addextras(data, fe_sqr, fe_log, fe_inv, fe_lag, interaction, removemissings)
    
    return data
end

function execute!(
    data::ModelSelection.ModelSelectionData;
    fe_sqr::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_log::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_inv::Union{Nothing, String, Symbol, Array{String}, Array{Symbol}}=nothing,
    fe_lag::Union{Nothing, Array}=nothing,
    interaction::Union{Nothing, Array, Dict}=nothing,
    removemissings::Bool=REMOVEMISSINGS_DEFAULT
    )

    if data.intercept
        ModelSelection.remove_intercept!(data)
    end

    if fe_sqr != nothing
        data = data_add_fe_sqr(data, parse_fe_variables(fe_sqr, data.expvars))
    end

    if fe_log != nothing
        data = data_add_fe_log(data, parse_fe_variables(fe_log, data.expvars))
    end

    if fe_inv != nothing
        data = data_add_fe_inv(data, parse_fe_variables(fe_inv, data.expvars))
    end

    if fe_lag != nothing
        data = data_add_fe_lag(data, parse_fe_variables(fe_lag, data.expvars, depvar=data.depvar, is_pair=true))
    end

    if interaction != nothing
        data = data_add_interaction(data, parse_fe_variables(interaction, data.expvars))
    end

    if data.intercept
        ModelSelection.add_intercept!(data)
    end

    if removemissings
        data = ModelSelection.filter_data_by_empty_values(data)
    end

    data = ModelSelection.convert_data(data)

    return data
end
