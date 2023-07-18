module AllSubsetRegression

using Distributed, Distributions, LinearAlgebra, SharedArrays, GLM

using ModelSelection
using ModelSelection:
    CONS, INVALID_METHOD, ModelSelectionData, ModelSelectionResult

export to_string, AllSubsetRegressionResult, ALLSUBSETREGRESSION_EXTRAKEY
export all_subset_regression

include("const.jl")
include("strings.jl")
include("utils.jl")
include("types/result.jl")
include("core.jl")

end
