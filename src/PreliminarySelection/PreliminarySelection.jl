module PreliminarySelection
    using GLMNet
    using ..ModelSelection

    export lasso!, lasso, lassoselection, PRELIMINARYSELECTION_EXTRAKEY, _lasso!, _lasso

    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")
end
