"""
    addextras!(
        data::ModelSelectionData,
        seasonaladjustment::Union{Dict{Symbol,Int64},Nothing},
        removeoutliers::Bool,
    )

Adds extra information to the ModelSelectionData object.
The function modifies the `data` object in-place and returns the modified object.
    
# Parameters
- `data::ModelSelectionData`: The ModelSelectionData object to which the extra information will be added.
- `seasonaladjustment::Union{Dict{Symbol,Int64},Nothing}`: Additional seasonal adjustment information.
- `removeoutliers::Bool`: A boolean indicating whether outliers should be removed.

# Example
!!! warning
    TODO: Pending example.
"""
function addextras!(
    data::ModelSelectionData,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing},
    removeoutliers::Bool,
)
    datanames = vcat(data.depvar, data.expvars)
    if data.fixedvariables !== nothing
        datanames = vcat(datanames, data.fixedvariables)
    end
    data.extras[PREPROCESSING_EXTRAKEY] =
        Dict(
            :datanames => datanames,
            :depvar => data.depvar,
            :expvars => data.expvars,
            :fixedvariables => data.fixedvariables,
            :data => DEFAULT_DATANAME,
            :datatype => data.datatype,
            :intercept => data.intercept,
            :panel => data.panel,
            :time => data.time,
            :seasonaladjustment => seasonaladjustment,
            :removeoutliers => removeoutliers,
            :removemissings => data.removemissings,
        )
    return data
end

"""
    equation_converts_wildcards(equation::Vector{String}, datanames::Vector{Symbol})

Converts an array of string variables and wildcards expressions in a vector of symbols.
It iterates over the elements of the equation vector and checks for wildcard expressions represented by the `*` or `.` character. It replaces the wildcard with matching datanames from the datanames vector and converts these to symbols.

# Parameters
- `equation::Vector{String}`: The equation vector.
- `datanames::Vector{Symbol}`: The vector of datanames to match against wildcard expressions.

# Returns
- `Vector{Symbol}`: The equation vector of symbols with wildcard expressions replaced by matching datanames.
- `Nothing`: If equation if empty after convertion.

# Example
```julia
equation = ["A*", "B*", "C", "D"]
datanames = [:A1, :A2, :B1, :B2, :C, :D]
new_equation = equation_converts_wildcards(equation, datanames)
# new_equation: [:A1, :A2, :B1, :B2, :C, :D]
```
```julia
equation = ["X", "Y*"]
datanames = [:A1, :A2, :B1, :B2, :C, :D]
new_equation = equation_converts_wildcards(equation, datanames)
# new_equation: nothing
```
"""
function equation_converts_wildcards(equation::Vector{String}, datanames::Vector{Symbol})
    new_equation::Vector{String} = []
    datanames_str::Vector{String} = map(String, datanames)
    for variable in equation
        variable = replace(variable, "." => "*")
        if variable[end] == '*'
            for name in datanames_str
                if name[1:length(variable[1:end-1])] == variable[1:end-1]
                    push!(new_equation, name)
                end
            end
        else
            if variable in datanames_str
                push!(new_equation, variable)
            end
        end
    end
    new_equation = unique(new_equation)
    if isempty(new_equation)
        return nothing
    end
    return map(Symbol, new_equation)
end

"""
    equation_str_to_strarr(equation::String)

Converts a string equation into an array of strings, where each element represents a variable or term in the equation.
The equation can contain variable names separated by spaces, commas, or plus signs. If the equation contains a tilde (~) symbol, it is split into two parts: the left-hand side and the right-hand side of the tilde. The right-hand side is further split into terms separated by plus signs. Each variable or term is stripped of leading and trailing whitespaces.
Available equations are:
- Stata like: `"y x1 x2 x3"`
- R like: `"y ~ x1 + x2 + x3"`
- Strings separated with comma: `"y,x1,x2,x3"`
- Using wildcars (`*` or `.`):
    - `"y *"`
    - `"y x*"`
    - `"y x1 z*"`
    - `"y ~ x*"`
    - `"y ~ ."`

# Parameters
- `equation::String`: The equation as a string.

# Returns
- `Vector{String}`: Array of strings representing the variables.

# Example
```julia
equation = equation_str_to_strarr("y ~ x1 + x2 + x3")
# equation: ["y", "x1", "x2", "x3"]
```
```julia
equation = equation_str_to_strarr("y x*")
# equation: ["y", "x*"]
```
"""
function equation_str_to_strarr(equation::String)
    equation_array = []
    if occursin("~", equation)
        vars = split(replace(equation, r"\s+|\s+$/g" => " "), "~")
        equation_array = [String(strip(var)) for var in vcat(vars[1], split(vars[2], "+"))]
    else
        equation_array = [
            String(strip(var)) for
            var in split(replace(equation, r"\s+|\s+$/g" => ","), ",")
        ]
    end
    equation_array = filter(x -> length(x) > 0, equation_array)
    return equation_array
end

"""
    filter_data_by_selected_columns(
        data::Union{
            Array{Float32},
            Array{Float64},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
        equation::Vector{Symbol},
        datanames::Vector{Symbol},
    )

Filter the data and datanames based on the selected equation columns.

# Parameters
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The input data, which can be an Array of Floats or an Array of Floats with Missing values.
- `equation::Vector{Symbol}`: The selected equation columns specified as a Vector of Symbols.
- `datanames::Vector{Symbol}`: The original datanames corresponding to the data columns.

# Returns
- `Tuple`: A tuple `(filtered_data, filtered_datanames)` where:
    - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64,Missing}}, Array{Union{Float32,Missing}}}`: The filtered data containing only the selected columns.
    - `datanames::Vector{Symbol}`: The corresponding datanames for the filtered data.

# Example
```julia
data = [1.0 2.0 3.0; 4.0 5.0 6.0; 7.0 8.0 9.0]
datanames = [:x, :y, :z]
equation = [:x, :z]

(filtered_data, filtered_datanames) = filter_data_by_selected_columns(data, equation, datanames)
# filtered_data: [1.0 3.0; 4.0 6.0; 7.0 9.0]
# filtered_datanames: [:x, :z]
```
"""
function filter_data_by_selected_columns(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    equation::Vector{Symbol},
    datanames::Vector{Symbol},
)
    columns = []
    for var in equation
        append!(columns, get_column_index(var, datanames))
    end
    data = data[:, columns]
    datanames = datanames[columns]
    return (data, datanames)
end

"""
    get_datanames(
        data::Union{
            Array{Float32},
            Array{Float64},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
            Tuple,
            DataFrame,
        };
        datanames::Union{Vector{Symbol},Nothing} = nothing,
    )

Get the datanames from the data or use the provided datanames if exists.

# Parameters
- `data::Union{Array{Float64},Array{Float32},Array{Union{Float32,Missing}},Array{Union{Float64,Missing}},Tuple,DataFrame}`: The data from which to extract the datanames.
- `datanames::Union{Vector{Symbol},Nothing}`: (optional) Predefined datanames. If provided, these will be used instead of extracting datanames from the data.

# Returns
- `datanames::Vector{Symbol}`: The extracted datanames as a vector of symbols.
- `Nothing`: if datanames is nothing and cannot be extracted from the data.

# Example
```julia
data = [1.0 2.0; 3.0 4.0]
datanames = get_datanames(data, [:x1, :x2])
# datanames: [:x1, :x2]
```
```julia
data = DataFrame(x1 = [1, 2, 3], x2 = [4, 5, 6])
datanames = get_datanames(data)
# datanames: [:x1, :x2]
```
```julia
data = [1.0 2.0; 3.0 4.0]
datanames = get_datanames(data)
# datanames: nothing
```
"""
function get_datanames(
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
    datanames::Union{Vector{Symbol},Nothing} = nothing,
)
    if datanames === nothing
        datanames = get_datanames_from_data(data)
    end
    if datanames === nothing || isempty(datanames)
        return nothing
    end
    datanames = Vector{Symbol}(map(Symbol, datanames))
end

"""
    get_datanames_from_data(
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
            Tuple,
            DataFrame,
        },
    )
        
Extracts variable names from `data` and converts them to a vector of strings.
If `data` is a DataFrame, it uses the column names. 
If `data` is a tuple, it assumes the second element contains the variable names and converts it to a vector.

# Parameters
- `data`: The data from which variable names are extracted.

# Returns
- `Vector{Symbol}`: An array of symbols representing the variable names.

# Example
```julia
data = DataFrame(A = [1, 2, 3], B = [4, 5, 6])
datanames = get_datanames_from_data(data)
# datanames: ["A", "B"]
"""
function get_datanames_from_data(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
        Tuple,
        DataFrame,
    },
)
    datanames = Vector{Symbol}()
    if isa(data, DataFrames.DataFrame)
        datanames = map(Symbol, names(data))
    elseif isa(data, Tuple) && !isa(data[2], Vector)
        datanames = map(Symbol, vec(data[2]))
    end
    return datanames
end

"""
    get_rawdata_from_data(
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float64,Missing}},
            Array{Union{Float32,Missing}},
            Tuple,
            DataFrame,
        },
    )

Extracts the raw data from the given `data` object and converts to an array

# Parameters
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}, Tuple, DataFrame}`: The input data object of type.

# Returns
- `Array{Union{Float64,Missing}}}: The raw data as an array`.

# Example
```julia
data_array = [1.0, 2.0, missing, 4.0]
raw_data_array = get_rawdata_from_data(data_array)
# raw_data_array: [1.0, 2.0, missing, 4.0]
```
```julia
using DataFrames
data_df = DataFrame(x = [1.0, 2.0, missing, 4.0])
raw_data_array = get_rawdata_from_data(data_df)
# raw_data_array: [1.0, 2.0, missing, 4.0]
```
```julia
data_tuple = ([1.0, 2.0, missing, 4.0],)
raw_data_array = get_rawdata_from_data(data_tuple)
# raw_data_array: [1.0, 2.0, missing, 4.0]
```
"""
function get_rawdata_from_data(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
        Tuple,
        DataFrame,
    },
)
    if isa(data, DataFrames.DataFrame)
        data = Array{Union{Float64,Missing}}(data)
    elseif isa(data, Tuple)
        data = data[1]
    end
    return data
end

"""
    remove_outliers!(
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
    )

Remove outliers from the given data.
This function calls the `remove_outliers!` function for each column of the data matrix/array, removing outliers individually.

# Parameters
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The input data.

# Returns
- `Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The original data with removed outliers.

# Example
!!! warning
    TODO: Pending example.
"""
function remove_outliers!(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
)
    for column = 1:size(data, 2)
        remove_outliers!(data, column)
    end
end

"""
    remove_outliers!(
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
        column::Int64,
    )

Remove outliers from a specific column of the given data.
The function uses the z-score method to identify outliers in the specified column and replaces them with `missing` values. Outliers are defined as data points that have a z-score greater than a threshold of 3.

# Parameters
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The input data.
- `column::Int64`: The column index to remove outliers from.

# Returns
- `Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The original data with removed outliers for the given column.
"""
function remove_outliers!(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    column::Int64,
)
    threshold = 3

    col = @view(data[:, column])
    aux_col = Array{Union{Int64,Float64,Missing}}(undef, size(col, 1), 2)
    for i in keys(col)
        aux_col[i, 1] = i
        aux_col[i, 2] = col[i]
    end

    valid_data = deleteat!(aux_col[:, 2], findall(ismissing, aux_col[:, 2]))

    mean_ = mean(valid_data)
    std_ = std(valid_data)

    for i in keys(col)
        if !ismissing(col[i])
            z_score = (col[i] - mean_) / std_
            if abs(z_score) > threshold
                col[i] = missing
            end
        end
    end
    return data
end

"""
    seasonal_adjustment!(
        data::Union{
            Array{Float32},
            Array{Float64},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
        datanames::Vector{Symbol},
        variables::Dict{Symbol,Int64},
    )

Perform seasonal adjustment on multiple variables in the data.
This function iterates over each variable specified in the variables dictionary and applies the seasonal adjustment using the seasonal_adjustment function.

# Parameters
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The input data to be seasonally adjusted.
- `datanames::Vector{Symbol}`: The datanames corresponding to the data columns.
- `variables::Dict{Symbol,Int64}: A dictionary where the keys are symbols representing the variable names to be seasonally adjusted, and the values are integers representing the factors for seasonal adjustment.

# Returns
- `Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The original data seasonal adjusted.

# Example
!!! warning
    TODO: Pending example.
"""
function seasonal_adjustment!(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    datanames::Vector{Symbol},
    variables::Dict{Symbol,Int64},
)
    for (name, factor) in variables
        seasonal_adjustment!(data, datanames, name, factor)
    end
    return data
end

"""
    seasonal_adjustment!(
        data::Union{
            Array{Float64},
            Array{Float32},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
        datanames::Vector{Symbol},
        name::Symbol,
        factor::Int64,
    )

Perform seasonal adjustment on a specific variable in the data.
This function applies seasonal adjustment to the specified variable in the data. It calculates the seasonal component using the `analyze` function and subtracts it from the variable to obtain the seasonally adjusted series. The `analyze` function analyzes the data using a window length determined by the factor, and returns the trend component (`yt`) and seasonal component (`ys`). The seasonal component is summed along the rows to obtain the total seasonal component. The function modifies the `data` array in-place and returns the modified data.

# Parameters
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The input data to be seasonally adjusted.
- `datanames::Vector{Symbol}`: The datanames corresponding to the data columns.
- `name::Symbol`: The symbol representing the name of the variable to be seasonally adjusted.
- `factor::Int64`: An integer representing the factor for seasonal adjustment.

# Returns
- `Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`: The original data seasonal adjusted.

# Example
!!! warning
    TODO: Pending example.
"""
function seasonal_adjustment!(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    datanames::Vector{Symbol},
    name::Symbol,
    factor::Int64,
)
    column = get_column_index(name, datanames)
    nobs = size(data, 2)
    col = @view(data[:, column])
    L = Int(round(nobs / 2 / factor)) * factor
    yt, ys = analyze(col, L)
    seasonal_component = sum(ys, dims = 2)
    col = col - seasonal_component
    return data
end

"""
    sort_data(
        data::Union{
            Array{Float32},
            Array{Float64},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
        datanames::Vector{Symbol};
        time::Union{Symbol,Nothing} = nothing,
        panel::Union{Symbol,Nothing} = nothing,
    )

Sorts the data based on the specified time and panel variables.

# Parameters
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64,Missing}}, Array{Union{Float32,Missing}}}`:: The input data, which can be an Array of Floats or an Array of Floats with Missing values.
- `datanames::Vector{Symbol}`: The datanames corresponding to the data columns.
- `time::Union{Symbol,Nothing}`: The variable representing time, specified as a Symbol. Defaults to `nothing`.
- `panel::Union{Symbol,Nothing}`: The variable representing panel data, specified as a Symbol. Defaults to `nothing`.

# Returns
- `Union{Array{Float64}, Array{Float32}, Array{Union{Float64,Missing}}, Array{Union{Float32,Missing}}}`: The sorted data, with rows rearranged based on the specified time and panel variables.

# Example
```julia
data = [2.0 30 40; 1.0 10 20; 3.0 50 60]
datanames = [:time, :y, :z]
time_var = :time
sorted_data = sort_data(data, datanames, time = time_var)
# sorted_data: [1.0 10 20; 2.0 30 40; 3.0 50 60]
```
```julia
data = [2.0 30 40; 1.0 10 20; 3.0 50 60]
datanames = [:panel, :y, :z]
panel_var = :panel
sorted_data = sort_data(data, datanames, panel = panel_var)
# sorted_data: [1.0 10 20; 2.0 30 40; 3.0 50 60]
```
```julia
data = [1 2.0 30 40; 2 1.0 70 80; 2 2.0 90 100; 1 1.0 10 20; 1 3.0 50 60]
datanames = [:panel, :time, :y, :z]
time_var = :time
panel_var = :panel
sorted_data = sort_data(data, datanames, panel = panel_var, time = time_var)
# sorted_data: [1.0 1.0 10 20; 1.0 2.0 30 40; 1.0 3.0 50 60; 2.0 1.0 70 80; 2.0 2.0 90 100]
```
"""
function sort_data(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    datanames::Vector{Symbol};
    time::Union{Symbol,Nothing} = nothing,
    panel::Union{Symbol,Nothing} = nothing,
)
    time_pos = get_column_index(time, datanames)
    panel_pos = get_column_index(panel, datanames)

    if time_pos !== nothing && panel_pos !== nothing
        data = sortslices(data, by = x -> (x[panel_pos], x[time_pos]), dims = 1)
    elseif panel_pos !== nothing
        data = sortslices(data, by = x -> (x[panel_pos]), dims = 1)
    elseif time_pos !== nothing
        data = sortslices(data, by = x -> (x[time_pos]), dims = 1)
    end
    return data
end

"""
    validate_panel(
        data::Union{
            Array{Float32},
            Array{Float64},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
        datanames::Vector{Symbol},
        panel::Symbol,
    )

Check if the panel variable in the data is valid, i.e., if it does not contain any missing values.

# Parameters
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64,Missing}}, Array{Union{Float32,Missing}}}`:: The input data, which can be an Array of Floats or an Array of Floats with Missing values.
- `datanames::Vector{Symbol}`: The datanames corresponding to the data columns.
- `panel::Symbol`: The variable representing panel data, specified as a Symbol.

# Returns
- `Bool`:
    - `true`: if the panel variable is valid (no missing values).
    - `false` if the panel variable contains missing values.

# Example
```julia
data = [1.0 2.0 3.0; 4.0 missing 6.0; 7.0 8.0 9.0]
datanames = [:panel, :y, :z]
panel_var = :panel
valid_panel = validate_panel(data, datanames, panel_var)
# valid_panel: true
```julia
data = [1.0 2.0 3.0; missing 5.0 6.0; 7.0 8.0 9.0]
datanames = [:panel, :y, :z]
panel_var = :panel
valid_panel = validate_panel(data, datanames, panel_var)
# valid_panel: false
```
"""
function validate_panel(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    datanames::Vector{Symbol},
    panel::Symbol,
)
    return !any(ismissing, data[:, get_column_index(panel, datanames)])
end

"""
    validate_time(
        data::Union{
            Array{Float32},
            Array{Float64},
            Array{Union{Float32,Missing}},
            Array{Union{Float64,Missing}},
        },
        datanames::Vector{Symbol},
        time::Union{Symbol};
        panel::Union{Symbol,Nothing} = nothing,
    )

Check if the time variable in the data is valid, i.e., if it represents a continuous sequence of values.

# Parameters
- `data::Union{Array{Float32}, Array{Float64}, Array{Union{Float32,Missing}}, Array{Union{Float64,Missing}}}`:: The input data, which can be an Array of Floats or an Array of Floats with Missing values.
- `datanames::Vector{Symbol}`: The datanames corresponding to the data columns.
- `time::Symbol`: The variable representing time data, specified as a Symbol.
- `panel::Union{Symbol,Nothong}`: The variable representing panel data, specified as a Symbol. Defaults to `nothing`.

# Returns
- `Bool`:
    - `true`: if the time variable is valid (represents a continuous sequence), or if no panel variable is specified.
    - `false` if the time variable does not represent a continuous sequence.

# Example
```julia
data = [1.0 10 20; 2.0 30 40; 3.0 50 60]
datanames = [:time, :x, :y, :z]
time_var = :time
valid_time = validate_time(data, datanames, time_var)
# valid_time: true
```
```julia
data = [1.0 10 20; 3.0 30 40; 4.0 50 60]
datanames = [:time, :x, :y]
time_var = :time
valid_time = validate_time(data, datanames, time_var)
# valid_time: false
```
```julia
data = [1.0 10 20; missing 30 40; 3.0 50 60]
datanames = [:time, :x, :y]
time_var = :time
valid_time = validate_time(data, datanames, time_var)
# valid_time: false
```
```julia
data = [1.0 1.0 10 20; 1.0 2.0 30 40; 2.0 1.0 50 60]
datanames = [:panel, :time, :x, :y]
time_var = :time
panel_var = :panel
valid_time = validate_time(data, datanames, time_var, panel = panel_var)
# valid_time: true
```
```julia
data = [1.0 1.0 10 20; 1.0 3.0 30 40; 2.0 1.0 50 60]
datanames = [:panel, :time, :x, :y]
time_var = :time
panel_var = :panel
valid_time = validate_time(data, datanames, time_var, panel = panel_var)
# valid_time: false
```
```julia
data = [1.0 1.0 10 20; 1.0 missing 30 40; 2.0 1.0 50 60]
datanames = [:panel, :time, :x, :y]
time_var = :time
panel_var = :panel
valid_time = validate_time(data, datanames, time_var, panel = panel_var)
# valid_time: false
```
"""
function validate_time(
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Float16},
        Array{Union{Float64,Missing}},
        Array{Union{Float32,Missing}},
        Array{Union{Float16,Missing}},
    },
    datanames::Vector{Symbol},
    time::Union{Symbol};
    panel::Union{Symbol,Nothing} = nothing,
)
    time_index = get_column_index(time, datanames)
    panel_index = get_column_index(panel, datanames)
    if panel === nothing
        previous_value = data[1, time_index]
        for value in data[2:end, time_index]
            if value === missing || previous_value + 1 != value
                return false
            end
            previous_value = value
        end
    else
        csis = unique(data[:, panel_index])
        for csi in csis
            rows = findall(x -> x == csi, data[:, panel_index])
            previous_value = data[rows[1], time_index]
            for row in rows[2:end]
                value = data[row, time_index]
                if value === missing || previous_value + 1 != value
                    return false
                end
                previous_value = value
            end
        end
    end
    return true
end
