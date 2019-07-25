mutable struct CrossValidationResult <: ModelSelection.ModelSelectionResult

    k::Int64
    s::Float64

    ttest
    datanames
    average_data
    median_data
    data

    function CrossValidationResult(
            k,
            s,
            ttest,
            datanames,
            average_data,
            median_data,
            data
        )
        new(k, s, ttest, datanames, average_data, median_data, data)
    end
end
