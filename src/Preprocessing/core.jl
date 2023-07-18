"""
    input(
        equation::String,
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float64,Missing}},
            Array{Union{Float32,Missing}},
            Tuple,
            DataFrame,
        };
        datanames::Union{Array{Symbol},Nothing} = nothing,
        method::Symbol = METHOD_DEFAULT,
        intercept::Bool = INTERCEPT_DEFAULT,
        fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
        panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
        time::Union{Symbol,Nothing} = TIME_DEFAULT,
        seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
        removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
        removemissings::Bool = REMOVEMISSINGS_DEFAULT,
        notify = NOTIFY_DEFAULT,
    )

Parse an string equation to an array of strings and call other functions to perform data preprocessing.

# Parameters
- `equation::String`: The equation in string format.
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}, DataFrame, Tuple}`: The input data.
- `datanames::Union{Array{Symbol},Nothing}`: (optional) Names of the variables in the data.
- `method::Symbol`: (optional) The method to use for format the data. Default is `METHOD_DEFAULT`.
- `intercept::Bool`: (optional) Whether to include an intercept in the model. Default is `INTERCEPT_DEFAULT`.
- `fixedvariables::Union{Symbol,Array{Symbol},Nothing}`: (optional) Fixed variables to include in the model. Default is `FIXED_VARIABLES_DEFAULT`.
- `panel::Union{Symbol,Nothing}`: (optional) Panel variable for panel data. Default is `PANEL_DEFAULT`.
- `time::Union{Symbol,Nothing}`: (optional) Time variable for time series data. Default is `TIME_DEFAULT`.
- `seasonaladjustment::Union{Dict{Symbol,Int64},Nothing}`: (optional) Seasonal adjustment parameters. Default is `SEASONALADJUSTMENT_DEFAULT`.
- `removeoutliers::Bool`: (optional) Whether to remove outliers from the data. Default is `REMOVEOUTLIERS_DEFAULT`.
- `removemissings::Bool`: (optional) Whether to remove missing values from the data. Default is `REMOVEMISSINGS_DEFAULT`.
- `notify`: (optional) Notification method. Default is `NOTIFY_DEFAULT`.

## Equation format
The `equation` parameter can be in the following formats:
```
# Stata-like string
equation = "y x1 x2 x3"

# R-like string
equation = "y ~ x1 + x2 + x3"

# Strings separated with comma
equation = "y,x1,x2,x3"

# Using wildcards
equation = "y *"
equation = "y x*"
equation = "y x1 z*"
equation = "y ~ x*"
equation = "y ~ ."
```

# Returns
- `modelselection_data`: The resulting model selection data.

# Example
!!! warning
    TODO: seasonaladjustment parameter missing.
```julia
equation = "y x1 x2"
data = [1.0 1.0 23 1.0 2.0 3.0; 1.0 2.0 33 4.0 5.0 6.0; 2.0 1.0 44 7.0 8.0 9.0]
datanames = [:panel, :time, :y, :x1, :x2, :x3]
job_notify(message::String, data::Union{Any,Nothing} = nothing) = println(message, data)

model = input(
    equation,
    data,
    datanames = datanames,
    method = :fast,
    intercept = true,
    fixedvariables = :x3,
    panel = :panel,
    time = :time,
    removeoutliers = true,
    removemissings = true,
    notify = job_notify,
)
# model: ModelSelectionData(
    equation=[:y, :x1, :x2],
    depvar=:y,
    expvars=[:x1, :x2, :_cons],
    fixedvariables=[:x3],
    panel=:panel,
    time=:time,
    intercept=true,
    datatype=Float32,
    method=:fast,
    nobs=3,
    # ...
)
```
"""
function input(
    equation::String,
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Symbol = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
    return input(
        equation_str_to_strarr(equation),
        data,
        datanames = datanames,
        method = method,
        intercept = intercept,
        fixedvariables = fixedvariables,
        panel = panel,
        time = time,
        seasonaladjustment = seasonaladjustment,
        removeoutliers = removeoutliers,
        removemissings = removemissings,
        notify = notify,
    )
end

"""
    input(
        equation::Vector{String},
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float64,Missing}},
            Array{Union{Float32,Missing}},
            Tuple,
            DataFrame,
        };
        datanames::Union{Array{Symbol},Nothing} = nothing,
        method::Symbol = METHOD_DEFAULT,
        intercept::Bool = INTERCEPT_DEFAULT,
        fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
        panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
        time::Union{Symbol,Nothing} = TIME_DEFAULT,
        seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
        removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
        removemissings::Bool = REMOVEMISSINGS_DEFAULT,
        notify = NOTIFY_DEFAULT,
    )

Converts the equation as vector of strings to a vector of symbols, parsing the wildcards and call other functions to perform data preprocessing.

# Parameters
- `equation::Array{String}`: The equation in string format.
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}, DataFrame, Tuple}`: The input data.
- `datanames::Union{Array{Symbol},Nothing}`: (optional) Names of the variables in the data.
- `method::Symbol`: (optional) The method to use for format the data. Default is `METHOD_DEFAULT`.
- `intercept::Bool`: (optional) Whether to include an intercept in the model. Default is `INTERCEPT_DEFAULT`.
- `fixedvariables::Union{Symbol,Array{Symbol},Nothing}`: (optional) Fixed variables to include in the model. Default is `FIXED_VARIABLES_DEFAULT`.
- `panel::Union{Symbol,Nothing}`: (optional) Panel variable for panel data. Default is `PANEL_DEFAULT`.
- `time::Union{Symbol,Nothing}`: (optional) Time variable for time series data. Default is `TIME_DEFAULT`.
- `seasonaladjustment::Union{Dict{Symbol,Int64},Nothing}`: (optional) Seasonal adjustment parameters. Default is `SEASONALADJUSTMENT_DEFAULT`.
- `removeoutliers::Bool`: (optional) Whether to remove outliers from the data. Default is `REMOVEOUTLIERS_DEFAULT`.
- `removemissings::Bool`: (optional) Whether to remove missing values from the data. Default is `REMOVEMISSINGS_DEFAULT`.
- `notify`: (optional) Notification method. Default is `NOTIFY_DEFAULT`.

## Equation format
The `equation` parameter can be in the following formats:
```
# Vector of strings
equation = ["y", "x1", "x2" "x3"]

# Using wildcards
equation = ["y", "*"]
equation = ["y", "x*"]
equation = ["y", "x1", "z*"]
```

# Returns
- `modelselection_data`: The resulting model selection data.

# Errors
- `ArgumentError(DATANAMES_REQUIRED)`: When `datanames` is not provided.
- `ArgumentError(VARIABLES_NOT_DEFINED)`: When `equation` contains undefined variables.

# Example
!!! warning
    TODO: seasonaladjustment parameter missing.
```julia
equation = ["y", "x1", "x2"]
data = [1.0 1.0 23 1.0 2.0 3.0; 1.0 2.0 33 4.0 5.0 6.0; 2.0 1.0 44 7.0 8.0 9.0]
datanames = [:panel, :time, :y, :x1, :x2, :x3]
job_notify(message::String, data::Union{Any,Nothing} = nothing) = println(message, data)

model = input(
    equation,
    data,
    datanames = datanames,
    method = :fast,
    intercept = true,
    fixedvariables = :x3,
    panel = :panel,
    time = :time,
    removeoutliers = true,
    removemissings = true,
    notify = job_notify,
)
# model: ModelSelectionData(
    equation=[:y, :x1, :x2],
    depvar=:y,
    expvars=[:x1, :x2, :_cons],
    fixedvariables=[:x3],
    panel=:panel,
    time=:time,
    intercept=true,
    datatype=Float32,
    method=:fast,
    nobs=3,
    # ...
)
```
"""
function input(
    equation::Vector{String},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Symbol = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
    datanames = get_datanames(data, datanames = datanames)
    if datanames === nothing
        throw(ArgumentError(DATANAMES_REQUIRED))
    end

    equation = equation_converts_wildcards(equation, datanames)
    if equation === nothing
        throw(ArgumentError(VARIABLES_NOT_DEFINED))
    end
    return input(
        equation,
        data,
        datanames = datanames,
        method = method,
        intercept = intercept,
        fixedvariables = fixedvariables,
        panel = panel,
        time = time,
        seasonaladjustment = seasonaladjustment,
        removeoutliers = removeoutliers,
        removemissings = removemissings,
        notify = notify,
    )
end

"""
    input(
        equation::Vector{Symbol},
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float64,Missing}},
            Array{Union{Float32,Missing}},
            Tuple,
            DataFrame,
        };
        datanames::Union{Array{Symbol},Nothing} = nothing,
        method::Symbol = METHOD_DEFAULT,
        intercept::Bool = INTERCEPT_DEFAULT,
        fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
        panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
        time::Union{Symbol,Nothing} = TIME_DEFAULT,
        seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
        removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
        removemissings::Bool = REMOVEMISSINGS_DEFAULT,
        notify = NOTIFY_DEFAULT,
    )

Process different values that are required for data process and validates that the data and the parameters are valid.
Converts the data to the selected type and call `excecute` function to perform data preprocessing.

# Parameters
- `equation::Array{String}`: The equation in string format.
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}, DataFrame, Tuple}`: The input data.
- `datanames::Union{Array{Symbol},Nothing}`: (optional) Names of the variables in the data.
- `method::Symbol`: (optional) The method to use for format the data. Default is `METHOD_DEFAULT`.
- `intercept::Bool`: (optional) Whether to include an intercept in the model. Default is `INTERCEPT_DEFAULT`.
- `fixedvariables::Union{Symbol,Array{Symbol},Nothing}`: (optional) Fixed variables to include in the model. Default is `FIXED_VARIABLES_DEFAULT`.
- `panel::Union{Symbol,Nothing}`: (optional) Panel variable for panel data. Default is `PANEL_DEFAULT`.
- `time::Union{Symbol,Nothing}`: (optional) Time variable for time series data. Default is `TIME_DEFAULT`.
- `seasonaladjustment::Union{Dict{Symbol,Int64},Nothing}`: (optional) Seasonal adjustment parameters. Default is `SEASONALADJUSTMENT_DEFAULT`.
- `removeoutliers::Bool`: (optional) Whether to remove outliers from the data. Default is `REMOVEOUTLIERS_DEFAULT`.
- `removemissings::Bool`: (optional) Whether to remove missing values from the data. Default is `REMOVEMISSINGS_DEFAULT`.
- `notify`: (optional) Notification method. Default is `NOTIFY_DEFAULT`.

# Returns
- `modelselection_data`: The resulting model selection data.

# Errors
- `ArgumentError(DATANAMES_REQUIRED)`: When `datanames` is not provided.
- `ArgumentError(INVALID_METHOD)`: When the specified `method` is invalid.
- `ArgumentError(SELECTED_VARIABLES_DOES_NOT_EXISTS)`: When one or more variables in `equation` are not present in `datanames`.
- `ArgumentError(SELECTED_FIXED_VARIABLES_DOES_NOT_EXISTS)`: When one or more fixed variables in `fixedvariables` are not present in `datanames`.
- `ArgumentError(SELECTED_FIXED_VARIABLES_IN_EQUATION)`: When one or more fixed variables in `fixedvariables` are also present in `equation`.
- `ArgumentError(TIME_VARIABLE_INEXISTENT)`: When the specified `time` variable does not exist in `datanames`.
- `ArgumentError(PANEL_VARIABLE_INEXISTENT)`: When the specified `panel` variable does not exist in `datanames`.

# Example
!!! warning
    TODO: seasonaladjustment parameter missing.
```julia
equation = [:y, :x1, :x2]
data = [1.0 1.0 23 1.0 2.0 3.0; 1.0 2.0 33 4.0 5.0 6.0; 2.0 1.0 44 7.0 8.0 9.0]
datanames = [:panel, :time, :y, :x1, :x2, :x3]
job_notify(message::String, data::Union{Any,Nothing} = nothing) = println(message, data)

model = input(
    equation,
    data,
    datanames = datanames,
    method = :fast,
    intercept = true,
    fixedvariables = :x3,
    panel = :panel,
    time = :time,
    removeoutliers = true,
    removemissings = true,
    notify = job_notify,
)
# model: ModelSelectionData(
    equation=[:y, :x1, :x2],
    depvar=:y,
    expvars=[:x1, :x2, :_cons],
    fixedvariables=[:x3],
    panel=:panel,
    time=:time,
    intercept=true,
    datatype=Float32,
    method=:fast,
    nobs=3,
    # ...
)
```
"""
function input(
    equation::Vector{Symbol},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
        Tuple,
        DataFrame,
    };
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Symbol = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
    notification(notify, NOTIFY_MESSAGE, progress=10)

    datanames = get_datanames(data, datanames = datanames)
    if datanames === nothing
        throw(ArgumentError(DATANAMES_REQUIRED))
    end

    datatype = get_datatype(method)
    if datatype === nothing
        throw(ArgumentError(INVALID_METHOD))
    end
    data = get_rawdata_from_data(data)

    if !in_vector(equation, datanames)
        msg = string(SELECTED_VARIABLES_DOES_NOT_EXISTS, ": ", equation[(!in).(equation, Ref(datanames))])
        throw(ArgumentError(msg))
    end

    if fixedvariables !== nothing
        if isa(fixedvariables, Symbol)
            fixedvariables = Vector([fixedvariables])
        end
        fixedvariables = Vector{Symbol}(fixedvariables)
        if !in_vector(fixedvariables, datanames)
            msg = string(SELECTED_FIXED_VARIABLES_DOES_NOT_EXISTS, ": ", fixedvariables[(!in).(fixedvariables, Ref(datanames))])
            throw(ArgumentError(msg))
        end
        if in_vector(fixedvariables, equation)
            msg = string(SELECTED_FIXED_VARIABLES_IN_EQUATION, ": ", fixedvariables[(in).(fixedvariables, Ref(equation))])
            throw(ArgumentError(msg))
        end
    end

    if !isa(data, Array{Union{Missing,datatype}}) || !isa(data, Array{Union{datatype}})
        data = Matrix{Union{Missing,datatype}}(data)
    end

    if time !== nothing
        if get_column_index(time, datanames) === nothing
            msg = string(TIME_VARIABLE_INEXISTENT, ": ", time)
            throw(ArgumentError(msg))
        end
    end

    if panel !== nothing
        if get_column_index(panel, datanames) === nothing
            msg = string(PANEL_VARIABLE_INEXISTENT, ": ", panel)
            throw(ArgumentError(msg))
        end
    end
    modelselection_data, method, seasonaladjustment, removeoutliers = execute(
        equation,
        data,
        datanames,
        method,
        intercept,
        datatype,
        fixedvariables = fixedvariables,
        panel = panel,
        time = time,
        seasonaladjustment = seasonaladjustment,
        removeoutliers = removeoutliers,
        removemissings = removemissings,
        notify = notify,
    )
    modelselection_data = addextras!(modelselection_data, seasonaladjustment, removeoutliers)
    notification(notify, NOTIFY_MESSAGE, progress=100)
    return modelselection_data
end

"""
    execute(
        equation::Vector{Symbol},
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float64,Missing}},
            Array{Union{Float32,Missing}},
        },
        datanames::Vector{Symbol},
        method::Symbol,
        intercept::Bool,
        datatype::DataType;
        fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
        panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
        time::Union{Symbol,Nothing} = TIME_DEFAULT,
        seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
        removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
        removemissings::Bool = REMOVEMISSINGS_DEFAULT,
        notify = NOTIFY_DEFAULT,
    )

Execute the model selection by performing data filtering, sorting, and conversion.

# Parameters
- `equation::Vector{Symbol}`: The equation in symbol format.
- `data`: The input data as an array.
- `datanames::Vector{Symbol}`: Names of the variables in the data.
- `method::Symbol`: The method to use for model selection.
- `intercept::Bool`: Whether to include an intercept in the model.
- `datatype::DataType`: The data type of the input data.
- `fixedvariables::Union{Symbol,Array{Symbol},Nothing}`: (optional) Fixed variables to include in the model. Default is `FIXED_VARIABLES_DEFAULT`.
- `panel::Union{Symbol,Nothing}`: (optional) Panel variable for panel data. Default is `PANEL_DEFAULT`.
- `time::Union{Symbol,Nothing}`: (optional) Time variable for time series data. Default is `TIME_DEFAULT`.
- `seasonaladjustment::Union{Dict{Symbol,Int64},Nothing}`: (optional) Seasonal adjustment parameters. Default is `SEASONALADJUSTMENT_DEFAULT`.
- `removeoutliers::Bool`: (optional) Whether to remove outliers from the data. Default is `REMOVEOUTLIERS_DEFAULT`.
- `removemissings::Bool`: (optional) Whether to remove missing values from the data. Default is `REMOVEMISSINGS_DEFAULT`.
- `notify`: (optional) Notification method. Default is `NOTIFY_DEFAULT`.

# Returns
- `modelselection_data::ModelSelectionData`: The resulting model selection data.
- `method::Symbol`: The method used for model selection.
- `seasonaladjustment::Union{Dict{Symbol,Int64},Nothing}`: The seasonal adjustment parameters used.
- `removeoutliers::Bool`: Whether outliers were removed.

# Errors
- `ArgumentError(DATANAMES_REQUIRED)`: When `datanames` is not provided.
- `ArgumentError(INVALID_METHOD)`: When the specified `method` is invalid.
- `ArgumentError(PANEL_ERROR)`: When there is an issue with the panel variable.
- `ArgumentError(TIME_ERROR)`: When there is an issue with the time variable.
- `ArgumentError(TIME_VARIABLE_INEXISTENT)`: When the specified `time` variable does not exist in `datanames`.
- `ArgumentError(VARIABLES_NOT_DEFINED)`: When the equation variables are not defined in `datanames`.

# Example
!!! warning
    TODO: seasonaladjustment parameter missing.
```julia
function job_notify(message::String, data::Union{Any,Nothing} = nothing)
    println(message, data)
end

data = [1.0 1.0 23 1.0 2.0 3.0; 1.0 2.0 33 4.0 5.0 6.0; 2.0 1.0 44 7.0 8.0 9.0]
model = execute(
    [:y, :x1, :x2],
    data,
    [:panel, :time, :y, :x1, :x2, :x3],
    :fast,
    true,
    Float32,
    fixedvariables = :x3,
    panel = :panel,
    time = :time,
    removeoutliers = true,
    removemissings = true,
    notify = job_notify,
)
# model: ModelSelectionData(
    equation=[:y, :x1, :x2],
    depvar=:y,
    expvars=[:x1, :x2, :_cons],
    fixedvariables=[:x3],
    panel=:panel,
    time=:time,
    intercept=true,
    datatype=Float32,
    method=:fast,
    nobs=3,
    # ...
)
```
"""
function execute(
    equation::Vector{Symbol},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    datanames::Vector{Symbol},
    method::Symbol,
    intercept::Bool,
    datatype::DataType;
    fixedvariables::Union{Symbol,Array{Symbol},Nothing} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
    notification(notify, NOTIFY_MESSAGE, progress=20)

    temp_equation = equation
    if fixedvariables !== nothing
        for fixedvariable in fixedvariables
            if get_column_index(fixedvariable, temp_equation) === nothing
                temp_equation = vcat(temp_equation, fixedvariable)
            end
        end
    end

    if panel !== nothing && get_column_index(panel, temp_equation) === nothing
        temp_equation = vcat(temp_equation, panel)
    end

    if time !== nothing && get_column_index(time, temp_equation) === nothing
        temp_equation = vcat(temp_equation, time)
    end

    (data, datanames) = filter_data_by_selected_columns(data, temp_equation, datanames)
    data = sort_data(data, datanames, panel = panel, time = time)

    panel_data = nothing
    if panel !== nothing
        if validate_panel(data, datanames, panel)
            panel_data = data[:, get_column_index(panel, datanames)]
        else
            throw(ArgumentError(PANEL_ERROR))
        end
    end

    time_data = nothing
    if time !== nothing
        if validate_time(data, datanames, time, panel = panel)
            time_data = data[:, get_column_index(time, datanames)]
        else
            throw(ArgumentError(TIME_ERROR))
        end
    end

    if seasonaladjustment !== nothing && time !== nothing
        seasonal_adjustment!(data, datanames, seasonaladjustment)
    elseif seasonaladjustment !== nothing && time === nothing
        throw(ArgumentError(TIME_VARIABLE_INEXISTENT))
    end

    fixedvariables_data = nothing
    if fixedvariables !== nothing
        cols = []
        for fixedvariable in fixedvariables
            push!(cols, get_column_index(fixedvariable, datanames))
        end
        fixedvariables_data = data[:, cols]
    end

    (data, datanames) = filter_data_by_selected_columns(data, equation, datanames)

    depvar = equation[1]
    expvars = equation[2:end]

    nobs = size(data, 1)

    if intercept
        data = hcat(data, ones(nobs))
        push!(expvars, CONS)
        push!(datanames, CONS)
    end

    if removeoutliers
        remove_outliers!(data)
    end

    depvar_data = data[1:end, 1]
    expvars_data = data[1:end, 2:end]

    if removemissings
        depvar_data, expvars_data, fixedvariables_data, time_data, panel_data =
            filter_raw_data_by_empty_values(
                datatype,
                depvar_data,
                expvars_data,
                fixedvariables_data,
                time_data,
                panel_data,
            )
    end

    depvar_data, expvars_data, fixedvariables_data, time_data, panel_data =
        convert_raw_data(
            datatype,
            depvar_data,
            expvars_data,
            fixedvariables_data,
            time_data,
            panel_data,
        )

    nobs = size(depvar_data, 1)
    modelselection_data = ModelSelectionData(
        equation,
        depvar,
        expvars,
        fixedvariables,
        time,
        panel,
        depvar_data,
        expvars_data,
        fixedvariables_data,
        time_data,
        panel_data,
        intercept,
        datatype,
        method,
        removemissings,
        nobs,
    )

    return modelselection_data, method, seasonaladjustment, removeoutliers
end
