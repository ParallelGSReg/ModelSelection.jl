module ModelSelection

    using DataFrames

    include("structs/modelselection_data.jl")
    include("datatypes/modelselection_result.jl")
    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")

    include("Preprocessing/Preprocessing.jl")
    include("FeatureExtraction/FeatureExtraction.jl")
    include("PreliminarySelection/PreliminarySelection.jl")
    include("AllSubsetRegression/AllSubsetRegression.jl")
    include("CrossValidation/CrossValidation.jl")
    include("Output/Output.jl")

    using ..Preprocessing
    using ..FeatureExtraction
    using ..PreliminarySelection
    using ..AllSubsetRegression
    using ..CrossValidation
    using ..Output

    export ModelSelectionData, ModelSelectionResult, gsr

    export Preprocessing, FeatureExtraction, PreliminarySelection, Output, CrossValidation

end
