# Usage

This section outlines the various options available to use the package.

## gsr() function

```julia
function gsr(
    estimator::Symbol,
    equation::Union{String,Array{String},Array{Symbol}},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Union{Symbol,Nothing} = nothing,
    intercept::Bool = Preprocessing.INTERCEPT_DEFAULT,
    panel::Union{Symbol,Nothing} = Preprocessing.PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = Preprocessing.TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = Preprocessing.SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = Preprocessing.REMOVEOUTLIERS_DEFAULT,
    fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
    interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
    preliminaryselection::Union{Symbol,Nothing} = nothing,
    fixedvariables::Union{Symbol,Vector{Symbol},Nothing} = AllSubsetRegression.FIXEDVARIABLES_DEFAULT,
    outsample::Union{Int64,Array{Int64},Nothing} = AllSubsetRegression.OUTSAMPLE_DEFAULT, # NOTE: Array posición de la observación
    criteria::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    ttest::Bool = AllSubsetRegression.TTEST_DEFAULT,
    ztest::Bool = AllSubsetRegression.ZTEST_DEFAULT,
    modelavg::Bool = AllSubsetRegression.MODELAVG_DEFAULT,
    residualtest::Bool = AllSubsetRegression.RESIDUALTEST_DEFAULT,
    orderresults::Bool = AllSubsetRegression.ORDERRESULTS_DEFAULT,
    kfoldcrossvalidation::Bool = CrossValidation.KFOLDCROSSVALIDATION_DEFAULT,
    numfolds::Int64 = CrossValidation.NUMFOLDS_DEFAULT,
    notify = nothing,
)
```

## Parameters
- `estimator::Symbol`: 
- `equation::Array{String}`:
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}, DataFrame, Tuple}`: The input data.
  
# Optional parameters
- `datanames::Union{Array{Symbol},Nothing}`: Names of the variables in the data.
- `method::Union{Symbol,Nothing}`: 
- `intercept::Bool`: Whether to include an intercept in the model. By default the GUM includes an intercept as a fixed covariate (e.g. it's included in every model). Alternatively, users can erase it by selecting the intercept=false boolean option. Default: `true`.
- `fe_sqr::Union{Symbol,Vector{Symbol},Nothing}`: Specifies the fixed extraction variables to be included in the model as squared terms. Default: `nothing`.
- `fe_log::Union{Symbol,Vector{Symbol},Nothing}`: Specifies the fixed extraction variables to be included in the model as logarithmic terms. Default: `nothing`.
- `fe_inv::Union{Symbol,Vector{Symbol},Nothing}`: Specifies the fixed effects variables to be included in the model as inverse terms. Default: `nothing`.
- `fe_lag::Union{Dict{Symbol,Int64},Nothing}`: Specifies the fixed effects variables to be included in the model as lagged terms. Default: `nothing`.
- `interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing}`: Specifies the interaction terms to be included in the model. Default: `nothing`.
- `preliminaryselection::Union{Symbol,Nothing}`: Specifies the preliminary variable selection method to be applied. Default: `nothing`.
- `fixedvariables::Union{Symbol,Vector{Symbol},Nothing}`: Specifies fixed variables that must be included in all model estimations. Default: `nothing`.
- `outsample::Union{Int64,Array{Int64},Nothing}`: Specifies the out-of-sample period to be used for model estimation. Default: `nothing`.

criteria::Union{Symbol,Vector{Symbol},Nothing}:

Description: Specifies the criteria to be used for model selection (optional).
Default: nothing.
ttest::Bool:

Description: Specifies whether to perform t-tests during the model estimation (optional).
Default: AllSubsetRegression.TTEST_DEFAULT.
ztest::Bool:

Description: Specifies whether to perform z-tests during the model estimation (optional).
Default: AllSubsetRegression.ZTEST_DEFAULT.
modelavg::Bool:

Description: Specifies whether to perform model averaging during the model estimation (optional).
Default: AllSubsetRegression.MODELAVG_DEFAULT.
residualtest::Bool:

Description: Specifies whether to perform residual tests during the model estimation (optional).
Default: AllSubsetRegression.RESIDUALTEST_DEFAULT.
orderresults::Bool:

Description: Specifies whether to order the results of the model estimation (optional).
Default: AllSubsetRegression.ORDERRESULTS_DEFAULT.
kfoldcrossvalidation::Bool:

Description: Specifies whether to use k-fold cross-validation during model selection (optional).
Default: CrossValidation.KFOLDCROSSVALIDATION_DEFAULT.
numfolds::Int64:

Description: Specifies the number of folds to be used in k-fold cross-validation (optional).
Default: CrossValidation.NUMFOLDS_DEFAULT.
notify:

Description: This parameter has no specific functionality and is optional.