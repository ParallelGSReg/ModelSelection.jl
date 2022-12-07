"""
Exports and returns summary result with file export.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `filename::String`: destination filename.
- `resultnum::Union{Int, Nothing}`: TODO add description.
"""
function summary(
	data::ModelSelection.ModelSelectionData,
	filename::String;
	resultnum::Union{Int, Nothing} = nothing,
)
	return summary(data, filename = filename, resultnum = resultnum)
end

"""
Exports and returns summary result with optional file export.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `filename::Union{String, Nothing}`: destination filename.
- `resultnum::Union{Int, Nothing}`: TODO add description.
"""
function summary(
	data::ModelSelection.ModelSelectionData;
	filename::Union{String, Nothing} = nothing,
	resultnum::Union{Int, Nothing} = nothing,
)
	addextras(data, :summary, filename, nothing)
	if size(data.results, 1) === 0
		return ""
	end
	if resultnum !== nothing
		return summary(data, data.results[resultnum], filename = filename)
	end
	outputstr = ""
	for i in axes(data.results, 1)
		outputstr = string(outputstr, summary(data, data.results[i]))
	end
	if filename !== nothing
		writefile(outputstr, filename)
	end
	return outputstr
end

"""
Exports results summary file with all subset regression result with file export.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult`: all subset regression result.
- `filename::String`: destination filename.
"""
function summary(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult,
	filename::String,
)
	return summary(data, result, filename = filename)
end

"""
Exports and returns results summary file with all subset regression result with optional file export.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult`: all subset regression result.
- `filename::Union{String, Nothing}`: destination filename.
"""
function summary(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult;
	filename::Union{String, Nothing} = nothing,
)
	outputstr = ModelSelection.AllSubsetRegression.to_string(data, result)
	if filename !== nothing
		writefile(outputstr, filename)
	end
	return outputstr
end

"""
Exports results summary file with cross validation result with file export.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.CrossValidation.CrossValidation`: cross validation result.
- `filename::String`: destination filename.
"""
function summary(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.CrossValidation.CrossValidationResult,
	filename::String,
)
	return summary(data, result, filename = filename)
end

"""
Exports results summary file with cross validation result with optional file export.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `result::ModelSelection.CrossValidation.CrossValidation`: cross validation result.
- `filename::Union{String, Nothing} `: destination filename.
"""
function summary(
	data::ModelSelection.ModelSelectionData,
	result::ModelSelection.CrossValidation.CrossValidationResult;
	filename::Union{String, Nothing} = nothing,
)
	outputstr = ModelSelection.CrossValidation.to_string(data, result)
	if filename !== nothing
		writefile(outputstr, filename)
	end
	return outputstr
end

"""
Writes summary file
# Arguments
- `outputstr::String`: output string.
- `filename::String`: output filename.
"""
function writefile(outputstr::String, filename::String)
	file = open(filename, "w")
	write(file, outputstr)
	close(file)
end
