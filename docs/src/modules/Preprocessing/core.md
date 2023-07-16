# Core

This section of the documentation is dedicated to explaining the purpose and usage core functions used throughout the Preprocessing module.

## Contents

```@contents
Pages = ["core.md"]
```

## Index

```@index
Pages = ["core.md"]
```

## Functions

```@docs
Preprocessing.input(
    equation::String,
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Symbol = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
Preprocessing.input(
    equation::Vector{String},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Symbol = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
Preprocessing.input(
    equation::Vector{Symbol},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Symbol = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
Preprocessing.execute(
    equation::Vector{Symbol},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
    },
    datanames::Vector{Symbol},
    method::Symbol,
    intercept::Bool,
    datatype::DataType;
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
```
