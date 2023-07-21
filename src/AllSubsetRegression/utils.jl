"""
    create_result(
        data::ModelSelectionData,
        outsample::Union{Int64,Vector{Int},Nothing},
        criteria::Vector{Symbol},
        modelavg::Bool,
        residualtest::Bool,
        orderresults::Bool;
        ttest::Union{Bool,Nothing} = nothing,
        ztest::Union{Bool,Nothing} = nothing,
    ) -> AllSubsetRegressionResult

Create an `AllSubsetRegressionResult` object containing the results of the model selection
process.

# Parameters
- `data::ModelSelectionData`: The data object containing information about the model
   selection process.
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
   Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform a residual test on the selected models.
- `orderresults::Bool`: If `true`, order the results based on the selection criteria.
   Default: `ORDERRESULTS_DEFAULT`.

# Optional Keyword Arguments
- `ttest::Union{Bool, Nothing}`: If `true`, perform t-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.
- `ztest::Union{Bool, Nothing}`: If `true`, perform z-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.

# Returns
- `AllSubsetRegressionResult`: An object containing the results of the model selection
  process.

# Example
```julia
result = create_result(data, 10, [:aic, :bic], true, false, true, ttest = true)
```
"""
function create_result(
    estimator::Symbol,
    method::Symbol,
    data::ModelSelectionData,
    outsample::Union{Int64,Vector{Int64},Nothing},
    criteria::Vector{Symbol},
    modelavg::Bool,
    residualtest::Bool,
    orderresults::Bool,
    equation_general_information::Vector{Symbol};
    ttest::Union{Bool,Nothing} = nothing,
    ztest::Union{Bool,Nothing} = nothing,
)
    validate_test(ttest = ttest, ztest = ztest)

    outsample = outsample === nothing ? 0 : outsample
    if (outsample isa Array && size(outsample, 1) > 0) ||
       (!(outsample isa Array) && outsample > 0)
        push!(criteria, :rmseout)
    end
    criteria = unique(criteria)
    datanames = create_datanames(
        data,
        estimator,
        criteria,
        modelavg,
        residualtest,
        equation_general_information,
        ttest = ttest,
        ztest = ztest,
    )
    modelavg_datanames::Union{Vector{Symbol},Nothing} = modelavg ? [] : nothing
    outsample_max =
        data.nobs - INSAMPLE_MIN - size(data.expvars, 1) - ((data.intercept) ? 1 : 0)
    outsample = isa(outsample, Int) && outsample_max <= outsample ? 0 : outsample
    return AllSubsetRegressionResult(
        estimator,
        datanames,
        method,
        modelavg_datanames,
        outsample,
        criteria,
        modelavg,
        residualtest,
        orderresults,
        ttest = ttest,
        ztest = ztest,
    )
end

"""
    create_datanames(
        data::ModelSelectionData,
        criteria::Vector{Symbol},
        ttest::Bool,
        modelavg::Bool,
        residualtest::Bool;
        ttest::Union{Bool,Nothing} = nothing,
        ztest::Union{Bool,Nothing} = nothing,
    ) -> Vector{Symbol}

Create a vector of data names (Symbols) representing the output of the model selection
process.

# Parameters
- `data::ModelSelectionData`: The data object containing information about the model
   selection process.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection. Default: `CRITERIA_DEFAULT`.
- `ttest::Bool`: If `true`, perform a t-test on the model coefficients.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.
   Default: `RESIDUALTEST_DEFAULT`.

# Optional Keyword Arguments
- `ttest::Union{Bool, Nothing}`: If `true`, perform t-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.
- `ztest::Union{Bool, Nothing}`: If `true`, perform z-tests for the coefficient estimates.
   If ttest and ztest are both `true`, throw an error.

# Returns
- `Vector{Symbol}`: A vector of data names representing the output of the model selection
  process.

# Example
```julia
datanames = create_datanames(data, [:aic, :bic], false, true, ttest=true)
```
"""
function create_datanames(
    data::ModelSelectionData,
    estimator::Symbol,
    criteria::Vector{Symbol},
    modelavg::Bool,
    residualtest::Bool,
    equation_general_information::Vector{Symbol};
    ttest::Union{Bool,Nothing} = nothing,
    ztest::Union{Bool,Nothing} = nothing,
)
    validate_test(ttest = ttest, ztest = ztest)

    datanames::Vector{Symbol} = []
    push!(datanames, INDEX)

    test = false
    if ttest == true
        test = true
        test_suffix = "_t"
    elseif ztest == true
        test = true
        test_suffix = "_z"
    end

    for expvar in data.expvars
        if expvar == CONS
            continue
        end
        push!(datanames, Symbol(string(expvar, "_b")))
        if test
            push!(datanames, Symbol(string(expvar, "_bstd")))
            push!(datanames, Symbol(string(expvar, test_suffix)))
        end
    end
    if data.fixedvariables !== nothing
        for fixedvar in data.fixedvariables
            push!(datanames, Symbol(string(fixedvar, "_b")))
            if test
                push!(datanames, Symbol(string(fixedvar, "_bstd")))
                push!(datanames, Symbol(string(fixedvar, test_suffix)))
            end
        end
    end
    if data.intercept !== nothing && data.intercept
        push!(datanames, Symbol(string(CONS, "_b")))
        if test
            push!(datanames, Symbol(string(CONS, "_bstd")))
            push!(datanames, Symbol(string(CONS, test_suffix)))
        end
    end

    testfields = []
    if (residualtest !== nothing && residualtest)
        if (data.time !== nothing)
            testfields = ESTIMATORS[estimator][RESIDUAL_TESTS_TIME]
        else
            testfields = ESTIMATORS[estimator][RESIDUAL_TESTS_CROSS]
        end
    end

    general_information_criteria = unique([equation_general_information; criteria; testfields])

    datanames = vcat(datanames, general_information_criteria)
    push!(datanames, ORDER)
    if modelavg !== nothing && modelavg
        push!(datanames, WEIGHT)
    end
    return datanames
end

"""
    get_insample_subset(
        depvar_data::Union{SharedVector{<:Union{Float64, Float32, Nothing}}},
        expvars_data::Union{SharedMatrix{<:Union{Float64, Float32, Nothing}}},
        fixedvariables_data::Union{
            SharedArray{<:Union{Float64, Float32, Nothing}},
            Nothing
        },
        outsample::Union{Int64, Vector{Int64}},
        selected_variables_index::Vector{Int64},
    ) -> Tuple{Vector, Matrix, Union{Matrix, Nothing}}

Retrieve the in-sample data subsets from the provided data.

# Parameters
- `depvar_data::Union{SharedVector{<:Union{Float64, Float32, Nothing}}}`: The data for
   the dependent variable.
- `expvars_data::Union{SharedMatrix{<:Union{Float64, Float32, Nothing}}}`:  The data for
   the explanatory variables.
- `fixedvariables_data::Union{SharedArray{<:Union{Float64, Float32, Nothing}}, Nothing}`:
   The data for the fixed variables, or `nothing` if no fixed variables are present.
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
  observations to be used for out-of-sample validation. Set to `nothing` if no
  out-of-sample validation is desired.
- `selected_variables_index::Vector{Int64}`: The indices of the selected explanatory
  variables.

# Returns
- `Tuple{Vector, Matrix, Union{Matrix, Nothing}}`: A tuple containing the in-sample subsets 
   of dependent variable data, explanatory variables data, and fixed variables data
   (if present).

# Example
```julia
depvar_view, expvars_view, fixedvariables_view =
    get_insample_subset(depvar_data, expvars_data, fixedvariables_data, 10, [1, 2, 4])
```
"""
function get_insample_subset(
    depvar_data::Union{
        SharedArrays.SharedVector{Float64},
        SharedArrays.SharedVector{Float32},
        SharedArrays.SharedVector{Float16},
        SharedArrays.SharedVector{Union{Float64,Nothing}},
        SharedArrays.SharedVector{Union{Float32,Nothing}},
        SharedArrays.SharedVector{Union{Float16,Nothing}},
    },
    expvars_data::Union{
        SharedArrays.SharedMatrix{Float64},
        SharedArrays.SharedMatrix{Float32},
        SharedArrays.SharedMatrix{Float16},
        SharedArrays.SharedMatrix{Union{Float64,Nothing}},
        SharedArrays.SharedMatrix{Union{Float32,Nothing}},
        SharedArrays.SharedMatrix{Union{Float16,Nothing}},
    },
    fixedvariables_data::Union{
        SharedArrays.SharedArray{Float64},
        SharedArrays.SharedArray{Float32},
        SharedArrays.SharedArray{Float16},
        SharedArrays.SharedArray{Union{Float64,Nothing}},
        SharedArrays.SharedArray{Union{Float32,Nothing}},
        SharedArrays.SharedArray{Union{Float16,Nothing}},
        Nothing,
    },
    outsample::Union{Int64,Vector{Int64}},
    selected_variables_index::Vector{Int64},
)
    depvar_view = nothing
    expvars_view = nothing
    fixedvariables_view = nothing
    if isa(outsample, Array)
        insample = setdiff(1:size(depvar_data, 1), outsample)
        depvar_view = depvar_data[insample, 1]
        expvars_view = expvars_data[insample, selected_variables_index]
        if fixedvariables_data !== nothing
            fixedvariables_view = fixedvariables_data[insample, :]
        end
    else
        depvar_view = depvar_data[1:end-outsample, 1]
        expvars_view = expvars_data[1:end-outsample, selected_variables_index]
        if fixedvariables_data !== nothing
            fixedvariables_view = fixedvariables_data[1:end-outsample, :]
        end
    end
    return depvar_view, expvars_view, fixedvariables_view
end

"""
    get_outsample_subset(
        depvar_data::Union{SharedVector{<:Union{Float64, Float32, Nothing}}},
        expvars_data::Union{SharedMatrix{<:Union{Float64, Float32, Nothing}}},
        fixedvariables_data::Union{
            SharedArray{<:Union{Float64, Float32, Nothing}}, 
            Nothing,
        },
        outsample::Union{Int64, Vector{Int64}},
        selected_variables_index::Vector{Int64},
    ) -> Tuple{Vector, Matrix, Union{Matrix, Nothing}}

Retrieve the out-of-sample data subsets from the provided data.

# Parameters
- `depvar_data::Union{SharedVector{<:Union{Float64, Float32, Nothing}}}`: The data for the
   dependent variable.
- `expvars_data::Union{SharedMatrix{<:Union{Float64, Float32, Nothing}}}`: The explanatory
   variables data.
- `fixedvariables_data::Union{SharedArray{<:Union{Float64, Float32, Nothing}}, Nothing}`:
   The data for the fixed variables, or `nothing` if no fixed variables are present.
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired.
- `selected_variables_index::Vector{Int64}`: The indices of the selected explanatory
   variables.

# Returns
- `Tuple{Vector, Matrix, Union{Matrix, Nothing}}`: A tuple containing the out-of-sample
   subsets of dependent variable data, explanatory variables data, and fixed variables data
   (if present).

# Example
```julia
depvar_view, expvars_view, fixedvariables_view = 
    get_outsample_subset(depvar_data, expvars_data, fixedvariables_data, 10, [1, 2, 4])
```
"""
function get_outsample_subset(
    depvar_data::Union{
        SharedArrays.SharedVector{Float64},
        SharedArrays.SharedVector{Float32},
        SharedArrays.SharedVector{Float16},
        SharedArrays.SharedVector{Union{Float64,Nothing}},
        SharedArrays.SharedVector{Union{Float32,Nothing}},
        SharedArrays.SharedVector{Union{Float16,Nothing}},
    },
    expvars_data::Union{
        SharedArrays.SharedMatrix{Float64},
        SharedArrays.SharedMatrix{Float32},
        SharedArrays.SharedMatrix{Float16},
        SharedArrays.SharedMatrix{Union{Float64,Nothing}},
        SharedArrays.SharedMatrix{Union{Float32,Nothing}},
        SharedArrays.SharedMatrix{Union{Float16,Nothing}},
    },
    fixedvariables_data::Union{
        SharedArrays.SharedArray{Float64},
        SharedArrays.SharedArray{Float32},
        SharedArrays.SharedArray{Float16},
        SharedArrays.SharedArray{Union{Float64,Nothing}},
        SharedArrays.SharedArray{Union{Float32,Nothing}},
        SharedArrays.SharedArray{Union{Float16,Nothing}},
        Nothing,
    },
    outsample::Union{Int64,Vector{Int64}},
    selected_variables_index::Vector{Int64},
)
    depvar_view = nothing
    expvars_view = nothing
    fixedvariables_view = nothing
    if isa(outsample, Array)
        depvar_view = depvar_data[outsample, 1]
        expvars_view = expvars_data[outsample, selected_variables_index]
        if fixedvariables_data !== nothing
            fixedvariables_view = fixedvariables_data[outsample, :]
        end
    else
        depvar_view = depvar_data[end-outsample+1:end, 1]
        expvars_view = expvars_data[end-outsample+1:end, selected_variables_index]
        if fixedvariables_data !== nothing
            fixedvariables_view = fixedvariables_data[end-outsample+1:end, :]
        end
    end
    return depvar_view, expvars_view, fixedvariables_view
end

"""
    sortrows(
        B::AbstractMatrix,
        cols::Array;
        kws...,
    ) -> AbstractMatrix

Sort the rows of a given matrix `B` based on the specified columns `cols`.

# Parameters
- `B::AbstractMatrix`: The input matrix to be sorted.
- `cols::Array`: An array containing the indices of the columns by which to sort the rows of
   the matrix.
- `kws...`: Optional keyword arguments to be passed to the `sortperm` function.

# Returns
- `AbstractMatrix`: A matrix with rows sorted based on the specified columns.

# Example
```julia
A = [3 2 1; 1 3 2; 2 1 3]
sorted_matrix = sortrows(A, [2, 3])
```
"""
function sortrows(B::AbstractMatrix, cols::Array; kws...)
    for i = 1:length(cols)
        if i == 1
            p = sortperm(B[:, cols[i]]; kws...)
            B = B[p, :]
        else
            i0_old = 0
            i1_old = 0
            i0_new = 0
            i1_new = 0
            for j = 1:size(B, 1)-1
                if B[j, cols[1:i-1]] == B[j+1, cols[1:i-1]] && i0_old == i0_new
                    i0_new = j
                elseif B[j, cols[1:i-1]] != B[j+1, cols[1:i-1]] &&
                       i0_old != i0_new &&
                       i1_new == i1_old
                    i1_new = j
                elseif i0_old != i0_new && j == size(B, 1) - 1
                    i1_new = j + 1
                end
                if i0_new != i0_old && i1_new != i1_old
                    p = sortperm(B[i0_new:i1_new, cols[i]]; kws...)
                    B[i0_new:i1_new, :] = B[i0_new:i1_new, :][p, :]
                    i0_old = i0_new
                    i1_old = i1_new
                end
            end
        end
    end
    return B
end

"""
    addextras!(
        data::ModelSelectionData,
        result::ModelSelectionResult,
    ) -> ModelSelectionData

Add extra information from a `ModelSelectionResult` to the `ModelSelectionData` object.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object to which the extra
   information will be added.
- `result::ModelSelectionResult`: The `ModelSelectionResult` object containing the extra
   information to be added.

# Returns
- `ModelSelectionData`: The updated `ModelSelectionData` object with the extra information
  added.

# Example
```julia
updated_data = addextras!(model_selection_data, model_selection_result)
```
"""
function addextras!(data::ModelSelectionData, result::ModelSelectionResult)
    extras = Dict(
        :datanames => result.datanames,
        :depvar => data.depvar,
        :expvars => data.expvars,
        :fixedvariables => data.fixedvariables,
        :panel => data.panel,
        :time => data.time,
        :nobs => data.nobs,
        :residualtest => result.residualtest,
        :criteria => result.criteria,
        :intercept => data.intercept,
        :outsample => result.outsample,
        :modelavg => result.modelavg,
        :orderresults => result.orderresults,
    )
    if result.ttest == true
        extras[:ttest] = result.ttest
    end
    if result.ztest == true
        extras[:ztest] = result.ztest
    end
    data.extras[ModelSelection.generate_extra_key(
        ALLSUBSETREGRESSION_EXTRAKEY,
        data.extras,
    )] = extras
    return data
end

"""
    valid_criteria(
        criteria::Vector{Symbol},
        available_criteria::Vector{Symbol},
    ) -> Bool

Check if the specified `criteria` are valid by comparing them to a list of
`available_criteria`.

# Parameters
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection.
- `available_criteria::Vector{Symbol}`: A vector of symbols representing the available
   criteria for comparison.

# Returns
- `Bool`: `true` if all elements in the `criteria` vector are present in the
  `available_criteria` vector, `false` otherwise.

# Example
```julia
is_valid = valid_criteria([:aic, :bic], [:aic, :bic, :rmse])
```
"""
function valid_criteria(criteria::Vector{Symbol}, available_criteria::Vector{Symbol})
    return ModelSelection.in_vector(criteria, available_criteria)
end

"""
    validate_criteria(criteria::Vector{Symbol}, available_criteria::Vector{Symbol})

Validate the given `criteria` against a list of `available_criteria`.

# Parameters
- `criteria`: A vector of symbols representing the criteria to be validated.
- `available_criteria`: A vector of symbols representing the available criteria.

# Returns
This function does not return any value. It raises an `ArgumentError` if any of the
    `criteria` is not valid.

# Examples
```julia
validate_criteria([:aic, :bic], [:aic, :bic, :aicc]) # No error
validate_criteria([:aic, :bad], [:aic, :bic, :aicc]) # ArgumentError
```
"""
function validate_criteria(criteria::Vector{Symbol}, available_criteria::Vector{Symbol})
    if !valid_criteria(criteria, available_criteria)
        msg = string(
            SELECTED_CRITERIA_IS_NOT_VALID,
            ": ",
            criteria[(!in).(criteria, Ref(available_criteria))],
        )
        throw(ArgumentError(msg))
    end
end

function validate_method(method::Symbol, available_methods::Vector{Symbol})
    if !(method in available_methods)
        methods = [string(method) for method in available_methods]
        error = INVALID_METHOD[1] * string(method) * INVALID_METHOD[2] * join(methods, ", ") * INVALID_METHOD[3]
        throw(ArgumentError(error))
    end
end

"""
    validate_test(ttest::Union{Bool, Nothing}, ztest::Union{Bool, Nothing})

Validates the test options specified by the user, ensuring that both t-test and z-test options are not simultaneously set to true.

# Parameters
- `ttest::Union{Bool, Nothing}`: Flag to indicate whether the t-test should be used (default: `nothing`)
- `ztest::Union{Bool, Nothing}`: Flag to indicate whether the z-test should be used (default: `nothing`)

# Throws
- `ArgumentError`: If both `ttest` and `ztest` are set to true, an ArgumentError is thrown with a message indicating that both cannot be true simultaneously.

# Example
```julia
validate_test(true, false) # No error
validate_test(false, true) # No error
validate_test(true, true)  # ArgumentError: "Both t-test and z-test cannot be true simultaneously."
``` 
"""
function validate_test(;
    ttest::Union{Bool,Nothing} = nothing,
    ztest::Union{Bool,Nothing} = nothing,
)
    if ttest == true && ztest == true
        throw(ArgumentError(TTEST_ZTEST_BOTH_TRUE))
    end
end

function validate_dataset(data::ModelSelectionData, outsample::Union{Int64,Vector{Int64}})
    if isa(outsample, Int64)
        outsample_obs = outsample
    else
        outsample_obs = size(outsample, 1)
    end
    fullexpvars = data.expvars
    if data.fixedvariables !== nothing
        fullexpvars = vcat(fullexpvars, data.fixedvariables)
    end
    if data.nobs - outsample_obs < size(fullexpvars, 1)
        throw(ArgumentError(TOO_MANY_COVARIATES))
    end
end

function validate_estimator(estimator::Symbol)
    if !(estimator in keys(ESTIMATORS))
        throw(ArgumentError(INVALID_ESTIMATOR))
    end
end

function get_datatype(estimator::Symbol, method::Union{Symbol,Nothing} = nothing)
    if estimator == OLS
        return get_ols_datatype(method)
    elseif estimator == LOGIT
        return get_logit_datatype(method)
    end
end

function get_ols_datatype(method::Union{Symbol,Nothing} = nothing)
    default = ESTIMATORS[OLS][METHOD][DEFAULT]
    available = ESTIMATORS[OLS][METHOD][AVAILABLE]
    return get_method_datatype(method, default, available)
end

function get_logit_datatype(method::Union{Symbol,Nothing} = nothing)
    default = ESTIMATORS[LOGIT][METHOD][DEFAULT]
    available = ESTIMATORS[LOGIT][METHOD][AVAILABLE]
    return get_method_datatype(method, default,available)
end

function get_method_datatype(
    method::Union{Symbol,Nothing},
    default::Symbol,
    available_methods::Vector{Symbol},
)   
    if method === nothing
        method = default
    end
    validate_method(method, available_methods)
    return METHODS_DATATYPES[method]
end
