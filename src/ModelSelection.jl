module ModelSelection

using DataFrames, JLD2

include("structs/modelselection_data.jl")
include("datatypes/modelselection_result.jl")
include("strings.jl")
include("const.jl")
include("utils.jl")

include("Preprocessing/Preprocessing.jl")
include("FeatureExtraction/FeatureExtraction.jl")
include("PreliminarySelection/PreliminarySelection.jl")
include("AllSubsetRegression/AllSubsetRegression.jl")
include("CrossValidation/CrossValidation.jl")

include("core.jl")

using ..Preprocessing
using ..FeatureExtraction
using ..PreliminarySelection
using ..AllSubsetRegression
using ..CrossValidation

Base.show(io::IO, data::ModelSelection.ModelSelectionData) = to_string(data)

export ModelSelectionData, ModelSelectionResult, gsr, save, load, save_csv

export Preprocessing, FeatureExtraction, PreliminarySelection, CrossValidation

end
