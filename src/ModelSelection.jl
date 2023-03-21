module ModelSelection

using DataFrames, JLD2

include("structs/modelselection_data.jl")
include("datatypes/modelselection_result.jl")
include("strings.jl")
include("const.jl")
include("utils.jl")
include("core.jl")

include("Preprocessing/Preprocessing.jl")
include("FeatureExtraction/FeatureExtraction.jl")
include("PreliminarySelection/PreliminarySelection.jl")
include("AllSubsetRegression/AllSubsetRegression.jl")
include("CrossValidation/CrossValidation.jl")

using ..Preprocessing
using ..FeatureExtraction
using ..PreliminarySelection
using ..AllSubsetRegression
using ..CrossValidation

export ModelSelectionData, ModelSelectionResult, gsr, save, load

export Preprocessing, FeatureExtraction, PreliminarySelection, CrossValidation

end
