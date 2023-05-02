"""
    create_result(
        data::ModelSelectionData,
        outsample::Union{Int64,Vector{Int},Nothing},
        criteria::Vector{Symbol},
        ttest::Bool,
        modelavg::Bool,
        residualtest::Bool,
        orderresults::Bool
    ) -> AllSubsetRegressionResult

Create an `AllSubsetRegressionResult` object containing the results of the model selection process.

# Arguments
- `data::ModelSelectionData`: The data object containing information about the model selection process.
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of observations to be used for out-of-sample validation. Set to `nothing` if no out-of-sample validation is desired.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison and selection.
- `ttest::Bool`: If `true`, perform a t-test on the model coefficients.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
- `residualtest::Bool`: If `true`, perform a residual test on the selected models.
- `orderresults::Bool`: If `true`, order the results based on the selection criteria.

# Returns
- `AllSubsetRegressionResult`: An object containing the results of the model selection process.

# Example
```julia
result = create_result(data, 10, [:aic, :bic], true, false, true, true)
```
"""
function create_result(
    data::ModelSelectionData,
    outsample::Union{Int64,Vector{Int},Nothing},
    criteria::Vector{Symbol},
    ttest::Bool,
    modelavg::Bool,
    residualtest::Bool,
    orderresults::Bool,
)
    outsample = outsample === nothing ? 0 : outsample
    if (outsample isa Array && size(outsample, 1) > 0) ||
       (!(outsample isa Array) && outsample > 0)
        push!(criteria, :rmseout)
    end
    criteria = unique(criteria)
    datanames = create_datanames(data, criteria, ttest, modelavg, residualtest)
    modelavg_datanames = modelavg ? [] : nothing
    outsample_max =
        data.nobs - INSAMPLE_MIN - size(data.expvars, 1) - ((data.intercept) ? 1 : 0)
    outsample = isa(outsample, Int) && outsample_max <= outsample ? 0 : outsample
    return AllSubsetRegressionResult(
        datanames,
        modelavg_datanames,
        outsample,
        criteria,
        modelavg,
        ttest,
        residualtest,
        orderresults,
    )
end

"""
    create_datanames(
        data::ModelSelectionData,
        criteria::Vector{Symbol},
        ttest::Bool,
        modelavg::Bool,
        residualtest::Bool
    ) -> Vector{Symbol}

Create a vector of data names (Symbols) representing the output of the model selection process.

# Arguments
- `data::ModelSelectionData`: The data object containing information about the model selection process.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison and selection.
- `ttest::Bool`: If `true`, perform a t-test on the model coefficients.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
- `residualtest::Bool`: If `true`, perform a residual test on the selected models.

# Returns
- `Vector{Symbol}`: A vector of data names representing the output of the model selection process.

# Example
```julia
datanames = create_datanames(data, [:aic, :bic], true, false, true)
```
"""
function create_datanames(
    data::ModelSelectionData,
    criteria::Vector{Symbol},
    ttest::Bool,
    modelavg::Bool,
    residualtest::Bool,
)
    datanames = []
    push!(datanames, INDEX)
    for expvar in data.expvars
        if expvar == CONS
            continue
        end
        push!(datanames, Symbol(string(expvar, "_b")))
        if ttest
            push!(datanames, Symbol(string(expvar, "_bstd")))
            push!(datanames, Symbol(string(expvar, "_t")))
        end
    end
    if data.fixedvariables !== nothing
        for fixedvar in data.fixedvariables
            push!(datanames, Symbol(string(fixedvar, "_b")))
            if ttest
                push!(datanames, Symbol(string(fixedvar, "_bstd")))
                push!(datanames, Symbol(string(fixedvar, "_t")))
            end
        end
    end
    if data.intercept !== nothing && data.intercept
        push!(datanames, Symbol(string(CONS, "_b")))
        if ttest
            push!(datanames, Symbol(string(CONS, "_bstd")))
            push!(datanames, Symbol(string(CONS, "_t")))
        end
    end
    testfields =
        (residualtest !== nothing && residualtest) ?
        ((data.time !== nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS) : []
    general_information_criteria =
        unique([EQUATION_GENERAL_INFORMATION; criteria; testfields])
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
        fixedvariables_data::Union{SharedArray{<:Union{Float64, Float32, Nothing}}, Nothing},
        outsample::Union{Int64, Vector{Int64}},
        selected_variables_index::Vector{Int64}
    ) -> Tuple{Vector, Matrix, Union{Matrix, Nothing}}

Retrieve the in-sample data subsets from the provided data.

# Arguments
- `depvar_data::Union{SharedVector{<:Union{Float64, Float32, Nothing}}}`: The dependent variable data.
- `expvars_data::Union{SharedMatrix{<:Union{Float64, Float32, Nothing}}}`: The explanatory variables data.
- `fixedvariables_data::Union{SharedArray{<:Union{Float64, Float32, Nothing}}, Nothing}`: The fixed variables data, or `nothing` if no fixed variables are present.
- `outsample::Union{Int64, Vector{Int64}}`: The number of observations or indices of observations to be used for out-of-sample validation.
- `selected_variables_index::Vector{Int64}`: The indices of the selected explanatory variables.

# Returns
- `Tuple{Vector, Matrix, Union{Matrix, Nothing}}`: A tuple containing the in-sample subsets of dependent variable data, explanatory variables data, and fixed variables data (if present).

# Example
```julia
depvar_view, expvars_view, fixedvariables_view = get_insample_subset(depvar_data, expvars_data, fixedvariables_data, 10, [1, 2, 4])
```
"""
function get_insample_subset(
    depvar_data::Union{
        SharedArrays.SharedVector{Float64},
        SharedArrays.SharedVector{Float32},
        SharedArrays.SharedVector{Union{Float32,Nothing}},
        SharedArrays.SharedVector{Union{Float64,Nothing}},
    },
    expvars_data::Union{
        SharedArrays.SharedMatrix{Float64},
        SharedArrays.SharedMatrix{Float32},
        SharedArrays.SharedMatrix{Union{Float32,Nothing}},
        SharedArrays.SharedMatrix{Union{Float64,Nothing}},
    },
    fixedvariables_data::Union{
        SharedArrays.SharedArray{Float64},
        SharedArrays.SharedArray{Float32},
        SharedArrays.SharedArray{Union{Float32,Nothing}},
        SharedArrays.SharedArray{Union{Float64,Nothing}},
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
        fixedvariables_data::Union{SharedArray{<:Union{Float64, Float32, Nothing}}, Nothing},
        outsample::Union{Int64, Vector{Int64}},
        selected_variables_index::Vector{Int64}
    ) -> Tuple{Vector, Matrix, Union{Matrix, Nothing}}

Retrieve the out-of-sample data subsets from the provided data.

# Arguments
- `depvar_data::Union{SharedVector{<:Union{Float64, Float32, Nothing}}}`: The dependent variable data.
- `expvars_data::Union{SharedMatrix{<:Union{Float64, Float32, Nothing}}}`: The explanatory variables data.
- `fixedvariables_data::Union{SharedArray{<:Union{Float64, Float32, Nothing}}, Nothing}`: The fixed variables data, or `nothing` if no fixed variables are present.
- `outsample::Union{Int64, Vector{Int64}}`: The number of observations or indices of observations to be used for out-of-sample validation.
- `selected_variables_index::Vector{Int64}`: The indices of the selected explanatory variables.

# Returns
- `Tuple{Vector, Matrix, Union{Matrix, Nothing}}`: A tuple containing the out-of-sample subsets of dependent variable data, explanatory variables data, and fixed variables data (if present).

# Example
```julia
depvar_view, expvars_view, fixedvariables_view = get_outsample_subset(depvar_data, expvars_data, fixedvariables_data, 10, [1, 2, 4])
```
"""
function get_outsample_subset(
    depvar_data::Union{
        SharedArrays.SharedVector{Float64},
        SharedArrays.SharedVector{Float32},
        SharedArrays.SharedVector{Union{Float32,Nothing}},
        SharedArrays.SharedVector{Union{Float64,Nothing}},
    },
    expvars_data::Union{
        SharedArrays.SharedMatrix{Float64},
        SharedArrays.SharedMatrix{Float32},
        SharedArrays.SharedMatrix{Union{Float32,Nothing}},
        SharedArrays.SharedMatrix{Union{Float64,Nothing}},
    },
    fixedvariables_data::Union{
        SharedArrays.SharedArray{Float64},
        SharedArrays.SharedArray{Float32},
        SharedArrays.SharedArray{Union{Float32,Nothing}},
        SharedArrays.SharedArray{Union{Float64,Nothing}},
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
        kws...
    ) -> AbstractMatrix

Sort the rows of a given matrix `B` based on the specified columns `cols`.

# Arguments
- `B::AbstractMatrix`: The input matrix to be sorted.
- `cols::Array`: An array containing the indices of the columns by which to sort the rows of the matrix.
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
    addextras(
        data::ModelSelectionData,
        result::ModelSelectionResult
    ) -> ModelSelectionData

Add extra information from a `ModelSelectionResult` to the `ModelSelectionData` object.

# Arguments
- `data::ModelSelectionData`: The input `ModelSelectionData` object to which the extra information will be added.
- `result::ModelSelectionResult`: The `ModelSelectionResult` object containing the extra information to be added.

# Returns
- `ModelSelectionData`: The updated `ModelSelectionData` object with the extra information added.

# Example
```julia
updated_data = addextras!(model_selection_data, model_selection_result)
```
"""
function addextras!(data::ModelSelectionData, result::ModelSelectionResult)
    data.extras[ModelSelection.generate_extra_key(
        ALLSUBSETREGRESSION_EXTRAKEY,
        data.extras,
    )] = Dict(
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
        :ttest => result.ttest,
        :outsample => result.outsample,
        :modelavg => result.modelavg,
        :orderresults => result.orderresults,
    )
    return data
end

"""
    valid_criteria(
        criteria::Vector{Symbol},
        available_criteria::Vector{Symbol}
    ) -> Bool

Check if the specified `criteria` are valid by comparing them to a list of `available_criteria`.

# Arguments
- `criteria::Vector{Symbol}`: A vector of symbols representing the criteria to be validated.
- `available_criteria::Vector{Symbol}`: A vector of symbols representing the available criteria for comparison.

# Returns
- `Bool`: `true` if all elements in the `criteria` vector are present in the `available_criteria` vector, `false` otherwise.

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

# Arguments
- `criteria`: A vector of symbols representing the criteria to be validated.
- `available_criteria`: A vector of symbols representing the available criteria.

# Returns
This function does not return any value. It raises an `ArgumentError` if any of the `criteria` is not valid.

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
