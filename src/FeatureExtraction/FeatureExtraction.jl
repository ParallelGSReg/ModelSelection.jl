module FeatureExtraction
    using Statistics
    using ShiftedArrays
    using ..ModelSelection

    export featureextraction!, featureextraction, FEATUREEXTRACTION_EXTRAKEY

    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")
end
