"""
Creates ModelSelection result
# Arguments
 - `data::ModelSelection.ModelSelectionData`: the model selection data.
 - `fixedvariables::Union{Nothing, Array}`: TODO add definition.
 - `outsample::Union{Nothing, Int, Array}`: TODO add definition.
 - `criteria::Array`: TODO add definition.
 - `ttest::Bool`: TODO add definition.
 - `modelavg::Bool`: TODO add definition.
 - `residualtest::Bool`: TODO add definition.
 - `orderresults::Bool`: TODO add definition.
"""
function create_result(
	data::ModelSelection.ModelSelectionData,
	fixedvariables::Union{Nothing, Array},
	outsample::Union{Nothing, Int, Array},
	criteria::Array,
	ttest::Bool,
	modelavg::Bool,
	residualtest::Bool,
	orderresults::Bool,
)
	if outsample === nothing
		outsample = 0
	end

	if (outsample isa Array && size(outsample, 1) > 0) || (!(outsample isa Array) && outsample > 0)
		push!(criteria, :rmseout)
	end

	criteria = unique(criteria)

	datanames = create_datanames(data, criteria, ttest, modelavg, residualtest)

	if modelavg
		modelavg_datanames = []
	else
		modelavg_datanames = nothing
	end

	outsample_max = data.nobs - INSAMPLE_MIN - size(data.expvars, 1) - if (data.intercept)
		1
	else
		0
	end

	if isa(outsample, Int) && outsample_max <= outsample
		outsample = 0
	end

	return AllSubsetRegressionResult(
		datanames,
		modelavg_datanames,
		fixedvariables,
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
 - `data::ModelSelection.ModelSelectionData`: the model selection data.
 - `criteria::Array`: TODO add definition.
 - `ttest::Bool`: TODO add definition.
 - `modelavg::Bool`: TODO add definition.
 - `residualtest::Bool`: TODO add definition.
 - `orderresults::Bool`: TODO add definition.
"""
function create_datanames(
	data::ModelSelection.ModelSelectionData,
	criteria::Array,
	ttest::Bool,
	modelavg::Bool,
	residualtest::Bool,
)
	datanames = []
	push!(datanames, INDEX)
	for expvar in data.expvars
		push!(datanames, Symbol(string(expvar, "_b")))
		if ttest
			push!(datanames, Symbol(string(expvar, "_bstd")))
			push!(datanames, Symbol(string(expvar, "_t")))
		end
	end
	testfields = (residualtest !== nothing && residualtest) ? ((data.time !== nothing) ? RESIDUAL_TESTS_TIME : RESIDUAL_TESTS_CROSS) : []
	general_information_criteria = unique([EQUATION_GENERAL_INFORMATION; criteria; testfields])
	datanames = vcat(datanames, general_information_criteria)
	push!(datanames, ORDER)
	if modelavg
		push!(datanames, WEIGHT)
	end
	return datanames
end

"""
Gets in-sample data view.
# Arguments
 - `depvar_data::Union{SharedArrays.SharedVector{Float64}, SharedArrays.SharedVector{Float32}, SharedArrays.SharedVector{Union{Float32, Nothing}}, SharedArrays.SharedVector{Union{Float64, Nothing}}}`: TODO add definition.
 - `expvars_data::Union{SharedArrays.SharedMatrix{Float64}, SharedArrays.SharedMatrix{Float32}, SharedArrays.SharedMatrix{Union{Float32, Nothing}}, SharedArrays.SharedMatrix{Union{Float64, Nothing}}}`: TODO add definition.
 - `outsample::Union{Int64, Vector{Int64}},`: TODO add definition.
 - `selected_variables_index::Vector{Int64}`: TODO add definition.
"""
function get_insample_subset(
	depvar_data::Union{SharedArrays.SharedVector{Float64}, SharedArrays.SharedVector{Float32}, SharedArrays.SharedVector{Union{Float32, Nothing}}, SharedArrays.SharedVector{Union{Float64, Nothing}}},
	expvars_data::Union{SharedArrays.SharedMatrix{Float64}, SharedArrays.SharedMatrix{Float32}, SharedArrays.SharedMatrix{Union{Float32, Nothing}}, SharedArrays.SharedMatrix{Union{Float64, Nothing}}},
	outsample::Union{Int64, Vector{Int64}},
	selected_variables_index::Vector{Int64},
)
	depvar_view = nothing
	expvars_view = nothing
	if isa(outsample, Array)
		insample = setdiff(1:size(depvar_data, 1), outsample)
		depvar_view = depvar_data[insample, 1]
		expvars_view = expvars_data[insample, selected_variables_index]
	else
		depvar_view = depvar_data[1:end-outsample, 1]
		expvars_view = expvars_data[1:end-outsample, selected_variables_index]
	end
	return depvar_view, expvars_view
end

"""
Gets out-sample data view.
# Arguments
- `depvar_data::Union{SharedArrays.SharedVector{Float64}, SharedArrays.SharedVector{Float32}, SharedArrays.SharedVector{Union{Float32, Nothing}}, SharedArrays.SharedVector{Union{Float64, Nothing}}}`: TODO add definition.
- `expvars_data::Union{SharedArrays.SharedMatrix{Float64}, SharedArrays.SharedMatrix{Float32}, SharedArrays.SharedMatrix{Union{Float32, Nothing}}, SharedArrays.SharedMatrix{Union{Float64, Nothing}}}`: TODO add definition.
- `outsample::Union{Int64, Vector{Int64}},`: TODO add definition.
- `selected_variables_index::Vector{Int64}`: TODO add definition.
"""
function get_outsample_subset(
	depvar_data::Union{SharedArrays.SharedVector{Float64}, SharedArrays.SharedVector{Float32}, SharedArrays.SharedVector{Union{Float32, Nothing}}, SharedArrays.SharedVector{Union{Float64, Nothing}}},
	expvars_data::Union{SharedArrays.SharedMatrix{Float64}, SharedArrays.SharedMatrix{Float32}, SharedArrays.SharedMatrix{Union{Float32, Nothing}}, SharedArrays.SharedMatrix{Union{Float64, Nothing}}},
	outsample::Union{Int64, Vector{Int64}},
	selected_variables_index::Vector{Int64},
)
	depvar_view = nothing
	expvars_view = nothing
	if isa(outsample, Array)
		depvar_view = depvar_data[outsample, 1]
		expvars_view = expvars_data[outsample, selected_variables_index]
	else
		depvar_view = depvar_data[end-outsample+1:end, 1]
		expvars_view = expvars_data[end-outsample+1:end, selected_variables_index]
	end
	return depvar_view, expvars_view
end

"""
Sorts rows.
# Arguments
 - `B::AbstractMatrix`: TODO add definition.
 - `cols::Array`: TODO add definition.
 - `kws...`: TODO add definition.
"""
function sortrows(B::AbstractMatrix, cols::Array; kws...)
	for i in 1:length(cols)
		if i == 1
			p = sortperm(B[:, cols[i]]; kws...)
			B = B[p, :]
		else
			i0_old = 0
			i1_old = 0
			i0_new = 0
			i1_new = 0
			for j in 1:size(B, 1)-1
				if B[j, cols[1:i-1]] == B[j+1, cols[1:i-1]] && i0_old == i0_new
					i0_new = j
				elseif B[j, cols[1:i-1]] != B[j+1, cols[1:i-1]] && i0_old != i0_new && i1_new == i1_old
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
TODO: Not being used
"""
function get_varnames(datanames)
	map(h -> chop("$h", tail = 2), filter(s -> endswith("$s", "_b"), datanames))
end

"""
Add extra data to data
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelectionResult`: the model selection result.
"""
function addextras(data::ModelSelection.ModelSelectionData, result::ModelSelection.ModelSelectionResult)
	data.extras[ModelSelection.generate_extra_key(ALLSUBSETREGRESSION_EXTRAKEY, data.extras)] = Dict(
		:datanames => result.datanames,
		:depvar => data.depvar,
		:expvars => data.expvars,
		:nobs => data.nobs,
		:time => data.time,
		:residualtest => result.residualtest,
		:criteria => result.criteria,
		:intercept => data.intercept,
		:ttest => result.ttest,
		:outsample => result.outsample,
		:modelavg => result.modelavg,
		:fixedvariables => result.fixedvariables,
		:orderresults => result.orderresults,
	)
	return data
end
