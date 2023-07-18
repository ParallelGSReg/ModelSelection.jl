module PreliminarySelection

using GLMNet
using ..ModelSelection

include("const.jl")
include("strings.jl")
include("utils.jl")
include("core.jl")

export preliminary_selection!, validate_estimator
export PRELIMINARYSELECTION_EXTRAKEY

end
