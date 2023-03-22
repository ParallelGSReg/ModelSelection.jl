include("strategies/lasso.jl")

function preliminary_selection(
    preliminaryselection::Union{Symbol,String},
    data::ModelSelection.ModelSelectionData,
)
    preliminaryselection = Symbol(preliminaryselection)

    if preliminaryselection == :lasso
        data = PreliminarySelection._lasso!(data)
    else
        throw(ArgumentError(INVALID_PRELIMINARYSELECTION))
    end
    return data
end
