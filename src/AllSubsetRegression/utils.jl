"""
Creates ModelSelection result
# Arguments
 - `data::ModelSelectionData`: the model selection data.
 - `outsample::Union{Int,Vector{Int},Nothing}`: TODO add definition.
 - `criteria::Vector{Symbol}`: TODO add definition.
 - `ttest::Bool`: TODO add definition.
 - `modelavg::Bool`: TODO add definition.
 - `residualtest::Bool`: TODO add definition.
 - `orderresults::Bool`: TODO add definition.
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
    if outsample === nothing
        outsample = 0
    end
    if (outsample isa Array && size(outsample, 1) > 0) ||
       (!(outsample isa Array) && outsample > 0)
        push!(criteria, :rmseout)
    end
    criteria = unique(criteria)
    datanames = create_datanames(data, criteria, ttest, modelavg, residualtest)
    modelavg_datanames = (modelavg) ? [] : nothing
    outsample_max = data.nobs - INSAMPLE_MIN - size(data.expvars, 1) - ((data.intercept) ? 1 : 0)
    if isa(outsample, Int) && outsample_max <= outsample
        outsample = 0
    end
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
Constructs the datanames array for results based on this structure:
Index,Covariates,b,bstd,T-test,Equation general information merged with criteria user-defined options,Order index from user combined criteria,Weight
# Arguments
 - `data::ModelSelectionData`: the model selection data.
 - `criteria::Vector{Symbol}`: TODO add definition.
 - `ttest::Bool`: TODO add definition.
 - `modelavg::Bool`: TODO add definition.
 - `residualtest::Bool`: TODO add definition.
 - `orderresults::Bool`: TODO add definition.
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
Gets in-sample data view TODO: Add fixed variables documentation
# Arguments
 - `depvar_data::Union{SharedArrays.SharedVector{Float64}, SharedArrays.SharedVector{Float32}, SharedArrays.SharedVector{Union{Float32,Nothing}}, SharedArrays.SharedVector{Union{Float64,Nothing}}}`: TODO add definition.
 - `expvars_data::Union{SharedArrays.SharedMatrix{Float64}, SharedArrays.SharedMatrix{Float32}, SharedArrays.SharedMatrix{Union{Float32,Nothing}}, SharedArrays.SharedMatrix{Union{Float64,Nothing}}}`: TODO add definition.
 - `outsample::Union{Int64, Vector{Int64}},`: TODO add definition.
 - `selected_variables_index::Vector{Int64}`: TODO add definition.
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
Gets out-sample data view.
# Arguments
- `depvar_data::Union{SharedArrays.SharedVector{Float64}, SharedArrays.SharedVector{Float32}, SharedArrays.SharedVector{Union{Float32,Nothing}}, SharedArrays.SharedVector{Union{Float64,Nothing}}}`: TODO add definition.
- `expvars_data::Union{SharedArrays.SharedMatrix{Float64}, SharedArrays.SharedMatrix{Float32}, SharedArrays.SharedMatrix{Union{Float32,Nothing}}, SharedArrays.SharedMatrix{Union{Float64,Nothing}}}`: TODO add definition.
- `outsample::Union{Int64, Vector{Int64}},`: TODO add definition.
- `selected_variables_index::Vector{Int64}`: TODO add definition.
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
Sorts rows.
# Arguments
 - `B::AbstractMatrix`: TODO add definition.
 - `cols::Array`: TODO add definition.
 - `kws...`: TODO add definition.
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
Add extra data to data
# Arguments
- `data::ModelSelectionData`: the model selection data.
- `result::ModelSelectionResult`: the model selection result.
"""
function addextras(
    data::ModelSelectionData,
    result::ModelSelection.ModelSelectionResult,
)
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
Validates if the selected criteria are valid
# Arguments
- `criteria::Vector{Symbol}: the selected criteria.
- `available_criteria::Vector{Symbol}`: the available criteria.
"""
function valid_criteria(criteria::Vector{Symbol}, available_criteria::Vector{Symbol})
    return ModelSelection.in_vector(criteria, available_criteria)
end

"""
Validates if the selected criteria are valid and throws an error if not
# Arguments
- `criteria::Vector{Symbol}: the selected criteria.
- `available_criteria::Vector{Symbol}`: the available criteria.
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
