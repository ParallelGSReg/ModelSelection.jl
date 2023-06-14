function notification(notify::Any, message::String, data::Any = nothing)
    if notify === nothing
        return
    end
    notify(message, data)
end
