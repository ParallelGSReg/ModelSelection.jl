"""
Add extra data to data
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `method::Symbol`: if the method is :fast or :precise.
- `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
- `removeoutliers::Bool`: TODO add description.
"""
function addextras(
    data::ModelSelection.ModelSelectionData,
    method::Symbol,
    seasonaladjustment::Union{Dict, Array, Nothing},
    removeoutliers::Bool,
)
	data.extras[ModelSelection.generate_extra_key(PREPROCESSING_EXTRAKEY, data.extras)] = Dict(
		:datanames => vcat(data.depvar, data.expvars),
		:depvar => data.depvar,
		:expvars => data.expvars,
		:data => DEFAULT_DATANAME,
		:method => method,
		:intercept => data.intercept,
		:panel => data.panel,
		:time => data.time,
		:seasonaladjustment => seasonaladjustment,
		:removeoutliers => removeoutliers,
		:removemissings => data.removemissings,
	)
	return data
end

"""
Converts a multiformat equation string vector to a string vector based on datanames.
# Arguments
- `equation::Vector{String}`: a multiformat (Stata, R, Julia, etc) equation string.
- `datanames::Union{Vector{String}, Vector{Symbol}}`: a structure of datanames.
"""
function equation_converts_wildcards!(equation::Vector{String}, datanames::Union{Vector{String}, Vector{Symbol}})
	new_equation::Vector{String} = []
	for e in equation
		e = replace(e, "." => "*")
		if e[end] == '*'
			datanames_arr = vec([String(key)[1:length(e[1:end-1])] == e[1:end-1] ? String(key) : nothing for key in datanames])
			append!(new_equation, filter!(x -> x !== nothing, datanames_arr))
		else
			append!(new_equation, [e])
		end
	end
	equation = unique(new_equation)
	return equation
end

"""
Converts a multiformat equation string to an array of variables and/or wildcards as string and returns it.
# Arguments
- `equation::String`: a multiformat (Stata, R, Julia, etc) equation string.
"""
function equation_str_to_strarr!(equation::String)
	if occursin("~", equation)
		vars = split(replace(equation, r"\s+|\s+$/g" => " "), "~")
		equation = [String(strip(var)) for var in vcat(vars[1], split(vars[2], "+"))]
	else
		equation = [String(strip(var)) for var in split(replace(equation, r"\s+|\s+$/g" => ","), ",")]
	end
	equation = filter(x -> length(x) > 0, equation)
	return equation
end

"""
Filters columns and keeps only selected ones.
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
- `depvar::Symbol`: the dependent variable.
- `expvars::Vector{Symbol}`: the explanatory variables.
- `datanames::Vector{Symbol}`: an array of stings and/or symbols.
"""
function filter_data_by_selected_columns(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	equation::Vector{Symbol},
	datanames::Vector{Symbol},
)
	columns = []
	for var in equation
		append!(columns, ModelSelection.get_column_index(var, datanames))
	end
	data = data[:, columns]
	datanames = datanames[columns]
	return (data, datanames)
end

"""
Gets DataFrame or Array from Tuple if is needed.
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
"""
function get_data_from_data(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame},
)
	if isa(data, DataFrames.DataFrame)
		data = Array{Union{Float64, Missing}}(data)
	elseif isa(data, Tuple)
		data = data[1]
	end
	return data
end

"""
Gets datanames from data structure and returns as a Vector.
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: input data.
- `datanames::Union{Nothing, Vector{String}, Vector{Symbol}}: an optional array of datanames.
"""
function get_datanames_from_data(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing},
	datanames::Union{Vector{String}, Vector{Symbol}, Nothing} = nothing,
)
	if isa(data, DataFrames.DataFrame)
		datanames = names(data)
	elseif isa(data, Tuple)
		datanames = data[2]
		if !isa(datanames, Vector)
			datanames = vec(datanames)
		end
	elseif (datanames === nothing)
		error(DATANAMES_REQUIRED)
	end
	return strarr_to_symarr!(datanames)
end

"""
Remove outliers from data
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
"""
function remove_outliers(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
)
	for column in 1:size(data, 2)
		remove_outlier(data, column)
	end
end

"""
Remove outliers from a data column
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
- `name::Int: column number.
"""
function remove_outlier(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	column::Int,
)
	threshold = 3

	col = @view(data[:, column])
	aux_col = Array{Union{Int64, Float64, Missing}}(undef, size(col, 1), 2)
	for i in keys(col)
		aux_col[i, 1] = i
		aux_col[i, 2] = col[i]
	end

	valid_data = deleteat!(aux_col[:, 2], findall(ismissing, aux_col[:, 2]))

	mean_ = mean(valid_data)
	std_ = std(valid_data)

	for i in keys(col)
		if !ismissing(col[i])
			z_score = (col[i] - mean_) / std_
			if abs(z_score) > threshold
				col[i] = missing
			end
		end
	end
	return data
end

"""
Seasonal adjustment from data 
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
- `factor_dict::Union{Dict, Array}`: TODO Set a definition.
- `datanames::Vector{Symbol}`: the datanames.
"""
function seasonal_adjustments(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	factor_dict::Union{Dict, Array},
	datanames::Vector{Symbol},
)
	for column in factor_dict
		seasonal_adjustment(data, column[1], column[2], datanames)
	end
end

"""
Seasonal adjustment from a data column
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
- `name::Symbol: variable name.
- `factor: TODO Set a type and definition.
- `datanames::Vector{Symbol}`: the datanames.
"""
function seasonal_adjustment(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	name::Symbol,
	factor,
	datanames::Vector{Symbol},
)
	column = ModelSelection.get_column_index(name, datanames)
	nobs = size(data, 2)
	col = @view(data[:, column])
	L = Int(round(nobs / 2 / factor)) * factor
	yt, ys = analyze(col, L)
	seasonal_component = sum(ys, dims = 2)
	col = col - seasonal_component
	return data
end

"""
Sorts data based on time or panel variables.
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
- `datanames::Vector{Symbol}`: the datanames.
- `time::Union{Symbol, Nothing}`: a time variable.
- `panel::Union{Symbol, Nothing}`: a panel variable.
"""
function sort_data(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	datanames::Vector{Symbol};
	time::Union{Symbol, Nothing} = nothing,
	panel::Union{Symbol, Nothing} = nothing,
)
	time_pos = ModelSelection.get_column_index(time, datanames)
	panel_pos = ModelSelection.get_column_index(panel, datanames)

	if time_pos !== nothing && panel_pos !== nothing
		data = sortslices(data, by = x -> (x[panel_pos], x[time_pos]), dims = 1)
	elseif panel_pos !== nothing
		data = sortslices(data, by = x -> (x[panel_pos]), dims = 1)
	elseif time_pos !== nothing
		data = sortslices(data, by = x -> (x[time_pos]), dims = 1)
	end
	return data
end

"""
Converts string and/or symbol datanames vector to symbol datanames vector and returns it.
# Arguments
- `arr::Union{Vector{AbstractString}, Vector{String}, Vector{Symbol}}`: an array of stings and/or symbols.
"""
function strarr_to_symarr!(arr::Union{Vector{AbstractString}, Vector{String}, Vector{Symbol}})
	return arr = [Symbol(str) for str in arr]
end

"""
Validates if there are panel gaps
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
- `datanames::Vector{Symbol}`: the datanames.
- `panel::Union{Symbol, Nothing}`: a panel variable.
"""
function validate_panel(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	datanames::Vector{Symbol};
	panel::Union{Symbol, Nothing},
)
	if panel !== nothing
		return !any(ismissing, data[:, ModelSelection.get_column_index(panel, datanames)])
	end
	return true
end

"""
Validates if there are time gaps
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: input data.
- `datanames::Vector{Symbol}`: the datanames.
- `time::Union{Symbol}`: a time variable.
- `panel::Union{Symbol, Nothing}`: a panel variable.
"""
function validate_time(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	datanames::Vector{Symbol};
	time::Union{Symbol},
    panel::Union{Symbol, Nothing},
)
    # TODO: Merge solutions
	if panel === nothing
		previous_value = data[1, ModelSelection.get_column_index(time, datanames)]
		for value in data[2:end, ModelSelection.get_column_index(time, datanames)]
			if previous_value + 1 != value
				return false
			end
			previous_value = value
		end
	else
		panel_index = ModelSelection.get_column_index(panel, datanames)
		csis = unique(data[:, panel_index])
		time_index = ModelSelection.get_column_index(time, datanames)
		for csi in csis
			rows = findall(x -> x == csi, data[:, panel_index])
			previous_value = data[rows[1], time_index]
			for row in rows[2:end]
				value = data[row, time_index]
				if previous_value + 1 != value
					return false
				end
				previous_value = value
			end
		end
	end
	return true
end
