function save(filename::String, data::ModelSelectionData)
    save_object(filename, data)
end

function load(filename::String)
    return load_object(filename)
end
