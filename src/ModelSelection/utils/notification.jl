function notification(notify, message::String, data::Any = nothing)
    println(message, data)
    if notify === nothing
        return
    end
    notify(Dict(NOTIFY_MESSAGE => message, NOTIFY_DATA => data))
end
