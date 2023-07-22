module ModelSelection

using DataFrames, DelimitedFiles, JLD2, Printf


include("ModelSelection/types.jl")
include("ModelSelection/strings.jl")
include("ModelSelection/const.jl")
include("ModelSelection/utils.jl")

include("Preprocessing/Preprocessing.jl")
include("FeatureExtraction/FeatureExtraction.jl")
include("PreliminarySelection/PreliminarySelection.jl")
include("AllSubsetRegression/AllSubsetRegression.jl")
include("CrossValidation/CrossValidation.jl")

include("ModelSelection/core.jl")

using ..Preprocessing
using ..FeatureExtraction
using ..PreliminarySelection
using ..AllSubsetRegression
using ..CrossValidation

export ModelSelectionData, ModelSelectionResult
export gsr, save, load, save_csv, to_dict, to_string
export create_datanames_index, get_column_index, get_selected_variables, convert_raw_data, in_vector, filter_raw_data_by_empty_values, generate_extra_key
export getresult, addresult!
export notification
export Preprocessing, FeatureExtraction, PreliminarySelection, CrossValidation
export CONS, AVAILABLE_METHODS, METHODS_DATATYPES, QR_64, QR_32, QR_16, CHO_64, CHO_32, CHO_16, SVD_64, SVD_32, SVD_16

end
