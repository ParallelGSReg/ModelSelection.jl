module FeatureExtraction

using ShiftedArrays, Statistics
using ShiftedArrays: lag
using ..ModelSelection

export featureextraction!, featureextraction, FEATUREEXTRACTION_EXTRAKEY

include("const.jl")
include("strings.jl")
include("utils.jl")
include("core.jl")

end
