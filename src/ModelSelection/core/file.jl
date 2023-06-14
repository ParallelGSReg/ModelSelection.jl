"""
Saves a jld2 file with ModelSelectionData data.
# Arguments
- `filename::String``: output filename.
- `data::ModelSelection.ModelSelectionData`: the model selection data.
"""
function save(filename::String, data::ModelSelectionData)
    save_object(filename, data)
end


"""
Loads a jld2 file to ModelSelectionData data variable.
# Arguments
- `filename::String``: input filename.
"""
function load(filename::String)
    return load_object(filename)
end
