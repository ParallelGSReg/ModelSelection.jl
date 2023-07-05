# Core

This section of the documentation is dedicated to explaining the purpose and usage core functions used throughout the FeatureExtraction module.

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
FeatureExtraction.featureextraction!(
    data::ModelSelection.ModelSelectionData;
    fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
    interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = nothing,
)
FeatureExtraction.execute!(
    data::ModelSelection.ModelSelectionData;
    fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
    interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = nothing,
)
```
