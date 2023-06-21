module CrossValidation

using ..ModelSelection
using Printf, Random, Statistics
import Base: iterate

export CrossValidationResult
export kfoldcrossvalidation, to_string
export CROSSVALIDATION_EXTRAKEY,
    KFOLDCROSSVALIDATION_DEFAULT, NUMFOLDS_DEFAULT, TESTSETSHARE_DEFAULT

include("const.jl")
include("utils.jl")
include("strings.jl")
include("structs/result.jl")
include("core.jl")

end
