# TODO: Add docstrings and typing
mutable struct AllSubsetRegressionResult <: ModelSelectionResult
    datanames::Vector{Symbol}
    modelavg_datanames::Any

    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Nothing,
    }
    bestresult_data::Union{Vector{Union{Int32,Int64,Float32,Float64,Missing}},Nothing}
    modelavg_data::Union{Vector{Union{Int32,Int64,Float32,Float64,Missing}},Nothing}

    outsample::Any
    criteria::Any
    modelavg::Any
    ttest::Any
    residualtest::Any
    orderresults::Any
    nobs::Any

    function AllSubsetRegressionResult(
        datanames,
        modelavg_datanames,
        outsample,
        criteria,
        modelavg,
        ttest,
        residualtest,
        orderresults,
    )
        new(
            datanames,
            modelavg_datanames,
            nothing,
            nothing,
            nothing,
            outsample,
            criteria,
            modelavg,
            ttest,
            residualtest,
            orderresults,
            0,
        )
    end
end
