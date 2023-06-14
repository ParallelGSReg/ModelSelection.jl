"""
Returns if feature extraction module was selected by the user.
# Arguments
- `fe_sqr::Union{Vector{Symbol}, Nothing}`: the square feature extraction symbols.
- `fe_log::Union{Vector{Symbol}, Nothing}`: the log feature extraction symbols.
- `fe_inv::Union{Vector{Symbol}, Nothing}`: the inverse feature extraction symbols.
- `fe_lag::Union{Array{Pair{Symbol, Int64}}, Array{Pair{String, Int64}}, Nothing}`: the lag feature extraction symbols.
- `interaction::Union{Vector{Symbol}, Nothing}`: the interaction feature extraction symbols.
"""
function featureextraction_enabled(
    fe_sqr::Union{String,Symbol,Array{String},Array{Symbol},Nothing},
    fe_log::Union{String,Symbol,Array{String},Array{Symbol},Nothing},
    fe_inv::Union{String,Symbol,Array{String},Array{Symbol},Nothing},
    fe_lag::Union{Array{Pair{Symbol,Int64}},Array{Pair{String,Int64}},Nothing},
    interaction::Union{Vector{Symbol},Nothing},
)
    return fe_sqr !== nothing ||
           fe_log !== nothing ||
           fe_inv !== nothing ||
           fe_lag !== nothing ||
           interaction !== nothing
end


"""
Returns if preliminary selection was selected by the user.
# Arguments
- `preliminaryselection::Union{Vector{Symbol}, Nothing}`: the preliminary selection option.
"""
function preliminaryselection_enabled(preliminaryselection::Union{Vector{Symbol},Nothing})
    return preliminaryselection !== nothing
end


"""
Returns if cross validation was selected by the user.
# Arguments
- `crossvalidation_enabled::Bool`: the preliminary selection.
"""
function crossvalidation_enabled(crossvalidation_enabled::Bool)
    return crossvalidation_enabled === true
end
