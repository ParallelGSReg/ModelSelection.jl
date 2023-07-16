
"""
Returns if preliminary selection was selected by the user.
# Parameters
- `preliminaryselection::Union{Symbol, Nothing}`: the preliminary selection option.
"""
function preliminaryselection_enabled(preliminaryselection::Union{Symbol,Nothing})
    return preliminaryselection !== nothing
end


"""
Returns if cross validation was selected by the user.
# Parameters
- `crossvalidation_enabled::Bool`: the preliminary selection.
"""
function crossvalidation_enabled(crossvalidation_enabled::Bool)
    return crossvalidation_enabled === true
end
