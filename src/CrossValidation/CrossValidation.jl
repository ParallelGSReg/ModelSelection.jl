module CrossValidation

using ..ModelSelection
using Printf, Random, Statistics
import Base: iterate

export kfoldcrossvalidation, CROSSVALIDATION_EXTRAKEY, CrossValidationResult, to_string

include("const.jl")
include("utils.jl")
include("strings.jl")
include("structs/result.jl")
include("core.jl")

end
