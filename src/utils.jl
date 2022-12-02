"""
Converts column by data DataType
# Arguments
- `datatype::Type`: the datatype.
- `column::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: column data.
"""
function convert_column(
	datatype::Type,
	column::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
)
	if column === nothing
		return column
	end
	has_missings = false
	if size(column, 2) == 1
		has_missings |= findfirst(x -> ismissing(x), column) != nothing
	else
		for i in axes(column, 2)
			has_missings |= findfirst(x -> ismissing(x), column[:, i]) != nothing
		end
	end

	if has_missings
		return Array{Union{Missing, datatype}}(column)
	end
	return Array{datatype}(column)
end

"""
Converts rawdata by data content
# Arguments
- `datatype::Type`: the datatype.
- `depvar_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}}`: dependent variable data.
- `expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: explanatory variables data.
- `time_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: time variable data.
- `panel_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: panel variable data.
"""
function convert_raw_data(
	datatype::Type,
	depvar_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}},
	expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	time_data::Union{Vector{Float64}, Vector{Float32}, Array{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}, Nothing} = nothing,
	panel_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}, Nothing} = nothing,
)
	depvar_data = convert_column(datatype, depvar_data)
	expvars_data = convert_column(datatype, expvars_data)
    if time_data !== nothing
        time_data = convert_column(datatype, time_data)
    end
    if panel_data !== nothing
	    panel_data = convert_column(datatype == Float64 ? Int64 : Int32, panel_data)
	end
	return depvar_data, expvars_data, time_data, panel_data
end

"""
Filters rawdata by empty values
# Arguments
- `datatype::Type`: the datatype.
- `depvar_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}}`: dependent variable data.
- `expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: explanatory variables data.
- `time_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: time variable data.
- `panel_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Nothing}`: panel variable data.
"""
function filter_raw_data_by_empty_values(
	datatype::Type,
	depvar_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}},
	expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
	time_data::Union{Vector{Float64}, Vector{Float32}, Array{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}, Nothing} = nothing,
	panel_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}, Nothing} = nothing,
)
	keep_rows = Array{Bool}(undef, size(depvar_data, 1))
	keep_rows .= true
	keep_rows .&= map(b -> !b, ismissing.(depvar_data))

	for i in axes(expvars_data, 2)
		keep_rows .&= map(b -> !b, ismissing.(expvars_data[:, i]))
	end

	depvar_data = convert(Array{datatype}, depvar_data[keep_rows, 1])
	expvars_data = convert(Array{datatype}, expvars_data[keep_rows, :])

	if panel_data !== nothing
		panel_data = panel_data[keep_rows, 1]
	end

	if time_data !== nothing
		time_data = time_data[keep_rows, 1]
	end

	return depvar_data, expvars_data, time_data, panel_data
end

"""
Gets the position of a name in names.
# Arguments
- `name::Union{String, Symbol}`: the name to find.
- `names::Union{Vector{String}, Vector{Symbol}}`: an array of stings and/or symbols.
"""
function get_column_index(name::Union{String, Symbol, Nothing}, names::Union{Vector{String}, Vector{Symbol}})
	if name === nothing
		return nothing
	end
	return findfirst(isequal(name), names)
end

"""
Returns if a vector is inside another vector.
# Arguments
- `sub_vector::Vector{Any}`: vector to match inside another vector.
- `vector::Vector{Any}`: vector that could contains the other vector.
"""
function in_vector(sub_vector::Any, vector::Any)
	for sv in sub_vector
		if !in(sv, vector)
			return false
		end
	end
	return true
end

"""
Filter data by empty values
"""
function filter_data_by_empty_values(data)
	depvar_data, expvars_data, time_data, panel_data = filter_raw_data_by_empty_values(
		data.datatype,
		data.depvar_data,
		data.expvars_data,
		data.time_data,
		data.panel_data,
	)

	data.depvar_data = depvar_data
	data.expvars_data = expvars_data
	data.panel_data = panel_data
	data.time_data = time_data
	data.nobs = size(data.depvar_data, 1)
	data.removemissings = true

	return data
end





"""
Convert data by data
"""
function convert_data(data)
	depvar_data, expvars_data, time_data, panel_data = convert_raw_data(
		data.datatype,
		data.depvar_data,
		data.expvars_data,
		data.time_data,
		data.panel_data,
	)
	data.depvar_data = depvar_data
	data.expvars_data = expvars_data
	data.panel_data = panel_data
	data.time_data = time_data

	return data
end

"""
Copy ModelSelectionData
"""
function copy_data(data::ModelSelectionData)
	new_data = ModelSelectionData(
		copy(data.equation),
		data.depvar,
		copy(data.expvars),
		data.time,
		data.panel,
		copy(data.depvar_data),
		copy(data.expvars_data),
		if (data.time_data !== nothing)
			copy(data.time_data)
		else
			data.time_data
		end,
		if (data.panel_data !== nothing)
			copy(data.panel_data)
		else
			data.panel_data
		end,
		data.intercept,
		data.datatype,
		data.removemissings,
		data.nobs,
	)

	new_data.extras = data.extras
	new_data.options = copy(data.options)
	new_data.previous_data = copy(data.previous_data)
	new_data.results = copy(data.results)

	return new_data
end

"""
Copy ModelSelectionData to another data
"""
function copy_data!(from_data::ModelSelectionData, to_data::ModelSelectionData)
	to_data.equation = from_data.equation
	to_data.depvar = from_data.depvar
	to_data.expvars = from_data.expvars
	to_data.panel = from_data.panel
	to_data.time = from_data.time
	to_data.depvar_data = from_data.depvar_data
	to_data.expvars_data = from_data.expvars_data
	to_data.panel_data = from_data.panel_data
	to_data.time_data = from_data.time_data
	to_data.intercept = from_data.intercept
	to_data.datatype = from_data.datatype
	to_data.removemissings = from_data.removemissings
	to_data.nobs = from_data.nobs
	to_data.extras = from_data.extras
	to_data.options = from_data.options
	to_data.previous_data = from_data.previous_data
	to_data.results = from_data.results

	return to_data
end

"""
Generate extra key
"""
function generate_extra_key(extra_key, extras)
	if !(extra_key in keys(extras))
		return extra_key
	else
		posfix = 2
		while Symbol(string(extra_key, "_", posfix)) in keys(extras)
			posfix = posfix + 1
		end
		return Symbol(string(extra_key, "_", posfix))
	end
end

"""
Returns if feature extraction module was selected
"""
function featureextraction_enabled(fe_sqr, fe_log, fe_inv, fe_lag, interaction)
	return fe_sqr != nothing || fe_log != nothing || fe_inv != nothing || fe_lag != nothing || interaction != nothing
end

"""
Returns if preliminary selection was selected
"""
function preliminaryselection_enabled(preliminaryselection)
	return preliminaryselection != nothing
end

"""
Validates if preliminary selecttion method exists
"""
function validate_preliminaryselection(preliminaryselection)
	return preliminaryselection in VALID_PRELIMINARYSELECTION
end

"""
Add result
"""
function addresult!(data, result)
	push!(data.results, result)

	return data
end

"""
Creates an array with keys and array positions
"""
function create_datanames_index(datanames)
	header = Dict{Symbol, Int64}()
	for (index, name) in enumerate(datanames)
		header[name] = index
	end
	return header
end


"""
Returns selected appropiate covariates for each iteration
"""
function get_selected_variables(order, datanames, intercept; fixedvariables = nothing, num_jobs = nothing, num_job = nothing, iteration_num = nothing)
	cols = zeros(Int64, 0)
	binary = string(order, base = 2)
	k = 1

	for order in 1:length(binary)
		if binary[length(binary)-order+1] == '1'
			push!(cols, k)
		end
		k = k + 1
	end
	if intercept
		push!(cols, ModelSelection.get_column_index(:_cons, datanames))
	end
	return cols
end

"""
Add intercept
"""
function add_intercept!(data)
	data.expvars_data = hcat(data.expvars_data, ones(data.nobs))
	push!(data.expvars, :_cons)
end

"""
Remove intercept
"""
function remove_intercept!(data)
	cons_index = get_column_index(:_cons, data.expvars)
	data.expvars_data = hcat(data.expvars_data[:, 1:cons_index-1], data.expvars_data[:, cons_index+1:end])
	data.expvars = vcat(data.expvars[1:cons_index-1], data.expvars[cons_index+1:end])
end
