"""
    AllSubsetRegressionResult(
        datanames::Vector{Symbol},
        modelavg_datanames::Union{Vector{Symbol},Nothing},
        outsample::Union{Int64,Vector{Int64},Nothing},
        criteria::Vector{Symbol},
        modelavg::Bool,
        ttest::Bool,
        residualtest::Bool,
        orderresults::Bool,
    )

A mutable struct representing the results of an all-subset regression model selection
process.

# Fields
- `datanames::Vector{Symbol}`: Names of the data series
- `modelavg_datanames::Union{Vector{Symbol},Nothing}`: Names of the data series for model
   averaging.
- `data::Union{...}`: Data series values.
- `bestresult_data::Union{Vector{Union{Int32,Int64,Float32,Float64,Missing}},Nothing}`: Data
   of the best model result.
- `modelavg_data::Union{Vector{Union{Int32,Int64,Float32,Float64,Missing}},Nothing}`: Data
   for model averaging
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
- `ttest::Union{Bool, Nothing}`: If `true`, perform t-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.
- `ztest::Union{Bool, Nothing}`: If `true`, perform z-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.
   Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results based on the selection criteria.
   Default: `ORDERRESULTS_DEFAULT`.
- `nobs::Int64`: Number of observations

# Example
```julia
result = AllSubsetRegressionResult(
    [:A, :B],
    [:C, :D],
    10,
    [:AIC, :BIC],
    true,
    true,
    true,
    ttest = true,
)
```
"""
mutable struct AllSubsetRegressionResult <: ModelSelectionResult
    estimator::Symbol
    datanames::Vector{Symbol}
    modelavg_datanames::Union{Vector{Symbol},Nothing}
    data::Union{
       Array{Float64},
        Array{Float32},
         Array{Float16},
         Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
         Array{Union{Float16,Missing}},
        Nothing,
    }
    bestresult_data::Union{Vector{Union{Int64,Int32,Int16,Float64,Float32,Float16,Missing}},Nothing}
    modelavg_data::Union{Vector{Union{Int64,Int32,Int16,Float64,Float32,Float16,Missing}},Nothing}
    outsample::Union{Int64,Vector{Int64},Nothing}
    criteria::Vector{Symbol}
    modelavg::Bool
    ttest::Union{Bool,Nothing}
    ztest::Union{Bool,Nothing}
    residualtest::Bool
    orderresults::Bool
    nobs::Int64

    function AllSubsetRegressionResult(
        estimator::Symbol,
        datanames::Vector{Symbol},
        modelavg_datanames::Union{Vector{Symbol},Nothing},
        outsample::Union{Int64,Vector{Int64},Nothing},
        criteria::Vector{Symbol},
        modelavg::Bool,
        residualtest::Bool,
        orderresults::Bool;
        ttest::Union{Bool,Nothing} = nothing,
        ztest::Union{Bool,Nothing} = nothing,
    )
        validate_test(ttest = ttest, ztest = ztest)
        new(
            estimator,
            datanames,
            modelavg_datanames,
            nothing,
            nothing,
            nothing,
            outsample,
            criteria,
            modelavg,
            ttest,
            ztest,
            residualtest,
            orderresults,
            0,
        )
    end
end
