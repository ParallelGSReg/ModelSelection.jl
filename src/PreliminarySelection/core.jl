include("strategies/lasso.jl")

function preliminary_selection!(
    preliminaryselection::Symbol,
    data::ModelSelection.ModelSelectionData;
    notify = nothing,
)
    if preliminaryselection == :lasso
        data = PreliminarySelection.lasso!(data; notify=notify)
    else
        throw(ArgumentError(INVALID_PRELIMINARYSELECTION))
    end
    return data
end
