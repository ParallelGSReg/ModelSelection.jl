module FeatureExtraction

using
    ShiftedArrays,
    Statistics
using ..ModelSelection

export featureextraction!, featureextraction, FEATUREEXTRACTION_EXTRAKEY

include("const.jl")
include("strings.jl")
include("utils.jl")
include("core.jl")

end
