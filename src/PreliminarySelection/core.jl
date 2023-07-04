include("strategies/lasso.jl")

function preliminary_selection(
    preliminaryselection::Union{Symbol,String},
    data::ModelSelection.ModelSelectionData;
    notify = nothing,
)
    return preliminary_selection!(
        preliminaryselection,
        ModelSelection.copy_modelselectiondata(data),
    )
end


function preliminary_selection!(
    preliminaryselection::Union{Symbol,String},
    data::ModelSelection.ModelSelectionData;
    notify = nothing,
)
    preliminaryselection = Symbol(preliminaryselection)

    if preliminaryselection == :lasso
        data = PreliminarySelection._lasso!(data; notify=notify)
    else
        throw(ArgumentError(INVALID_PRELIMINARYSELECTION))
    end
    return data
end
