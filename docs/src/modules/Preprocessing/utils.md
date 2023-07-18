# Utils

This section of the documentation is dedicated to explaining the purpose and usage of the utils function used throughout the Preprocessing module.

## Contents

```@contents
Pages = ["utils.md"]
```

## Index

```@index
Pages = ["utils.md"]
```

## Functions

```@docs
Preprocessing.addextras!(
    data::ModelSelection.ModelSelectionData,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing},
    removeoutliers::Bool,
)
Preprocessing.equation_converts_wildcards(equation::Vector{String}, datanames::Vector{Symbol})
Preprocessing.equation_str_to_strarr(equation::String)
Preprocessing.filter_data_by_selected_columns(
    data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    equation::Vector{Symbol},
    datanames::Vector{Symbol},
)
Preprocessing.get_datanames(
    data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Vector{Symbol},Nothing} = nothing,
)
Preprocessing.get_datanames_from_data(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
    },
)
Preprocessing.get_datatype(method::Symbol)
Preprocessing.get_rawdata_from_data(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Tuple,
        DataFrame,
    },
)
Preprocessing.remove_outliers!(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
)
Preprocessing.remove_outliers!(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    column::Int64,
)
Preprocessing.seasonal_adjustment!(
    data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    datanames::Vector{Symbol},
    variables::Dict{Symbol,Int64},
)
Preprocessing.seasonal_adjustment!(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    datanames::Vector{Symbol},
    name::Symbol,
    factor::Int64,
)
Preprocessing.sort_data(
    data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    datanames::Vector{Symbol};
    time::Union{Symbol,Nothing} = nothing,
    panel::Union{Symbol,Nothing} = nothing,
)
Preprocessing.validate_panel(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    datanames::Vector{Symbol},
    panel::Symbol,
)
Preprocessing.validate_time(
    data::Union{
        Array{Float32},
        Array{Float64},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    datanames::Vector{Symbol},
    time::Union{Symbol};
    panel::Union{Symbol,Nothing} = nothing,
)

```
