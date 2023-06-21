mutable struct CrossValidationResult <: ModelSelection.ModelSelectionResult
    k::Int64
    s::Float64

    ttest::Any
    datanames::Any
    average_data::Union{Matrix{Union{Int32,Int64,Float32,Float64,Missing}},Nothing}
    median_data::Union{Matrix{Union{Int32,Int64,Float32,Float64,Missing}},Nothing}
    data::Any

    function CrossValidationResult(k, s, ttest, datanames, average_data, median_data, data)
        new(k, s, ttest, datanames, average_data, median_data, data)
    end
end
