
function notification(notify, message::String, data::Union{Dict{Symbol,Any},Nothing} = nothing; progress::Union{Int64,Nothing} = nothing)
    if notify === nothing
        return
    end
    if progress !== nothing
        if data === nothing
            data = Dict{Symbol,Any}()
        end
        data[PROGRESS] = progress
    end
    notify(message, data)
end
