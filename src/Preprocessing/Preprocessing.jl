module Preprocessing

using DataFrames, SingularSpectrumAnalysis, Statistics
using ModelSelection
using ModelSelection: CONS, FAST, PRECISE, INVALID_METHOD

export input, PREPROCESSING_EXTRAKEY

include("const.jl")
include("strings.jl")
include("utils.jl")
include("core.jl")

end
