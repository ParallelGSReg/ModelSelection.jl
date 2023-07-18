mutable struct CrossValidationResult <: ModelSelection.ModelSelectionResult
    k::Int64
    
    ttest::Any
    ztest::Any
    datanames::Any
    average_data::Union{Matrix{Union{Int64,Int32,Int16,Float64,Float32,Float16,Missing}},Nothing}
    median_data::Union{Matrix{Union{Int64,Int32,Int16,Float64,Float32,Float16,Missing}},Nothing}
    data::Any

    function CrossValidationResult(k, ttest, ztest, datanames, average_data, median_data, data)
        new(k, ttest, ztest, datanames, average_data, median_data, data)
    end
end
