"""
Generates csv with file export.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `filename::String``: output filename.
- `resultnum::Int64`: TODO add description.
"""
function csv(
	data::ModelSelection.ModelSelectionData,
	filename::String;
	resultnum::Int64 = 1,
)
	csv(data, filename = filename, resultnum = resultnum)
end

"""
Exports to csv adding extras.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `filename::String: output filename.
- `resultnum::Int64`: TODO add description.
"""
function csv(
	data::ModelSelection.ModelSelectionData;
	filename::Union{String, Nothing} = nothing,
	resultnum::Int64 = 1,
)
	addextras(data, :csv, filename, nothing)
	if size(data.results, 1) === 0
		return ""
	end
	return csv(data, data.results[resultnum], filename = filename)
end

"""
Exports to csv with all subset regression result.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
- `filename::String: output filename.
"""
function csv(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult,
	filename::String,
)
	return csv(data, result, filename = filename)
end

"""
Exports and writes to csv file with all subset regression result.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
- `filename::String: output filename.
"""
function csv(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult;
	filename::Union{Nothing, String} = nothing,
)
	header = []
	for dataname in result.datanames
		push!(header, String(dataname))
	end
	rows = vcat(permutedims(header), result.data)
	if filename !== nothing
		file = open(filename, "w")
		writedlm(file, rows, ',')
		close(file)
	end
	res = ""
	for row in eachrow(rows)
		res *= @sprintf("%s\n", join(row, ','))
	end
	return res
end

"""
Exports to csv with cross validation result.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.CrossValidation.CrossValidationResult: cross validation result.
- `filename::String: output filename.
"""
function csv(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.CrossValidation.CrossValidationResult,
	filename::String,
)
	return csv(data, result, filename = filename)
end

"""
Exports and writes to csv file with cross validation result.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.CrossValidation.CrossValidationResult: cross validation result.
- `filename::String: output filename.
"""
function csv(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.CrossValidation.CrossValidationResult;
	filename::Union{Nothing, String} = nothing,
)
	header = []
	for dataname in result.datanames
		push!(header, String(dataname))
	end
	rows = vcat(permutedims(header), result.data)
	if filename !== nothing
		file = open(filename, "w")
		writedlm(file, rows, ',')
		close(file)
	end
	res = ""
	for row in eachrow(rows)
		res *= @sprintf("%s\n", join(row, ','))
	end
	return res
end
