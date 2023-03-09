module AllSubsetRegression

using
    Distributed,
    Distributions,
    LinearAlgebra,
    Printf,
    SharedArrays,
    GLM

using ..ModelSelection

export to_string, AllSubsetRegressionResult, ALLSUBSETREGRESSION_EXTRAKEY
export ols, ols!, logit, logit!

include("const.jl")
include("strings.jl")
include("utils.jl")
include("structs/result.jl")
include("core.jl")
include("estimators/ols.jl")
include("estimators/logit.jl")

end
