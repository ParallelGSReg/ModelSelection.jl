"""
Adds extra information to the model selection data.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `filename::String: output filename.
- `path::String`: output path.
"""
function addextras(
	data::ModelSelection.ModelSelectionData,
	outputtype::Symbol,
	filename::Union{String, Nothing} = nothing,
	path::Union{String, Nothing} = nothing
)
	data.extras[ModelSelection.generate_extra_key(OUTPUT_EXTRAKEY, data.extras)] = Dict(
		:outputtype => outputtype,
		:filename => filename,
		:path => path,
	)
	return data
end

"""
TODO: Add description.
"""
function get_array_details(arr::Array) # TODO: Better typing definition
	dict = Dict(arr)
	Dict(
		((length(arr) == 1) ? "var" : "vars") => Dict(
			"names" => map(string, collect(keys(dict))),
			"values" => collect(values(dict)),
		),
		((length(arr) == 1) ? "vars" : "var") => false,
	)
end

"""
TODO: Add description.
"""
function get_array_simple_details(arr::Array) # TODO: Better typing definition
	Dict(
		((length(arr) == 1) ? "var" : "vars") => Dict(
			"names" => map(string, arr),
		),
		((length(arr) == 1) ? "vars" : "var") => false,
	)
end
