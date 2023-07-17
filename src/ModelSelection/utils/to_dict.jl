function add_depvar(summary::Dict{Symbol,Any}, depvar::Symbol)
    summary[:depvar] = depvar
    return summary
end


# FIXME: Type
function get_best_covar(varname::Symbol, datanames_index, result, result_data)
    covar =
        Dict{Symbol,Any}(:b => result_data[datanames_index[Symbol(string(varname, "_b"))]])
    if result.ttest !== nothing && result.ttest
        covar[:bstd] = result_data[datanames_index[Symbol(string(varname, "_bstd"))]]
        covar[:t] = result_data[datanames_index[Symbol(string(varname, "_t"))]]
    end
    if result.ztest !== nothing && result.ztest
        covar[:bstd] = result_data[datanames_index[Symbol(string(varname, "_bstd"))]]
        covar[:z] = result_data[datanames_index[Symbol(string(varname, "_z"))]]
    end
    return covar
end


function add_best_covars(
    summary::Dict{Symbol,Any},
    name::Symbol,
    datanames_index::Dict{Symbol,Int64},
    covars::Vector{Symbol},
    result,
    result_data,
)
    summary[name] = Dict{Symbol,Any}()
    for varname in covars
        summary[name][varname] =
            get_best_covar(varname, datanames_index, result, result_data)
    end
    return summary
end


function add_summary_stats(
    summary::Dict{Symbol,Any},
    datanames_index,
    result_data;
    summary_variables = nothing,
    criteria_variables = nothing,
)
    if summary_variables !== nothing
        for stat_name in keys(summary_variables)
            summary[stat_name] = result_data[datanames_index[stat_name]]
        end
    end

    if criteria_variables !== nothing
        for stat_name in keys(criteria_variables)
            summary[stat_name] = result_data[datanames_index[stat_name]]
        end
    end
    return summary
end
