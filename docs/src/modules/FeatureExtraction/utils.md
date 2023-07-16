# Utils

This section of the documentation is dedicated to explaining the purpose and usage of the utils function used throughout the FeatureExtraction module.

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
FeatureExtraction.parse_fe_variables(
    fe_vars::Union{Symbol,Vector{Symbol},Dict{Symbol,Int64},Vector{Tuple{Symbol, Symbol}}},
    expvars::Vector{Symbol};
    depvar::Union{Symbol,Nothing} = nothing,
)
FeatureExtraction.data_add_fe_vars!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol},Dict{Symbol,Int64}},
    postfix::String,
    func,
)
FeatureExtraction.data_add_fe_sqr!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol}},
)
FeatureExtraction.data_add_fe_log!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol}},
)
FeatureExtraction.data_add_fe_inv!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Union{Symbol,Vector{Symbol}},
)
FeatureExtraction.data_add_fe_lag!(
    data::ModelSelection.ModelSelectionData,
    fe_vars::Dict{Symbol,Int64},
)
FeatureExtraction.data_add_interaction!(
    data::ModelSelection.ModelSelectionData,
    interaction::Vector{Tuple{Symbol,Symbol}},
)
```
