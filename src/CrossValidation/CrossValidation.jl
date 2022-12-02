module CrossValidation

using ..ModelSelection
using
    Printf,
    Random,
    Statistics
import Base: iterate

export kfoldcrossvalidation, CROSSVALIDATION_EXTRAKEY, CrossValidationResult

include("const.jl")
include("utils.jl")
include("strings.jl")
include("structs/result.jl")
include("core.jl")

end
