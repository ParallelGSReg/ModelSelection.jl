mutable struct CrossValidationResult <: ModelSelection.ModelSelectionResult
    k::Int64
    s::Float64

    ttest::Any
    datanames::Any
    average_data::Any
    median_data::Any
    data::Any

    function CrossValidationResult(k, s, ttest, datanames, average_data, median_data, data)
        new(k, s, ttest, datanames, average_data, median_data, data)
    end
end
