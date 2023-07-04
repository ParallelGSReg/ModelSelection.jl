function notification(notify, message::String, data::Union{Any,Nothing} = nothing)
    if notify === nothing
        return
    end
    notify(message, data)
end
