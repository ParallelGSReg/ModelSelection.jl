"""
Processes the input data based in a multiformat string equation and optional data and returns processed data.
# Arguments
 - `equation::String`: the multiformat string equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::String;
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    } = nothing,
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
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
    )
end

"""
Processes the input data based in a the string array equation and optional data and returns processed data.
 - `equation::Array{String}`: the string array equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Array{String};
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    } = nothing,
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    return input(
        equation,
        data,
        datanames = datanames,
        method = method,
        intercept = intercept,
        fixedvariables = fixedvariables,
        panel = panel,
        time = time,
        removeoutliers = removeoutliers,
        seasonaladjustment = seasonaladjustment,
        removemissings = removemissings,
    )
end

"""
Processes the input data based in a the string vector equation and optional data and returns processed data.
 - `equation::Vector{String}`: the string vector equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Vector{String};
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    } = nothing,
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    return input(
        equation,
        data,
        datanames = datanames,
        method = method,
        intercept = intercept,
        fixedvariables = fixedvariables,
        panel = panel,
        time = time,
        removeoutliers = removeoutliers,
        seasonaladjustment = seasonaladjustment,
        removemissings = removemissings,
    )
end

"""
Processes the input data based in a symbol array equation and optional data and returns processed data.
# Arguments
 - `equation::Array{Symbol}`: the symbol array equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Array{Symbol};
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    } = nothing,
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
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
    )
end

"""
Processes the input data based in a symbol vector equation and optional data and returns processed data.
# Arguments
 - `equation::Vector{Symbol}`: the vector symbol equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Vector{Symbol};
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    } = nothing,
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
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
    )
end

"""
Processes the input data based in a multiformat string equation and returns processed data.
# Arguments
 - `equation::String`: the multiformat string equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::String,
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    };
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    return input(
        equation_str_to_strarr!(equation),
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
    )
end

"""
Processes the input data based in a multiformat string array equation and returns processed data.
# Arguments
 - `equation::Array{String}`: the multiformat string array equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Array{String},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    };
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    equation = vec(equation)
    equation = Vector{String}(equation)
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
    )
end

"""
Processes the input data based in a multiformat string vector equation and returns processed data.
# Arguments
 - `equation::Vector{String}`: the multiformat vector string equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Vector{String},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    };
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    if datanames !== nothing
        datanames = Vector{String}(vec(datanames))
    end
    datanames = get_datanames_from_data(data, datanames)
    equation = equation_converts_wildcards!(equation, datanames)
    equation = strarr_to_symarr!(equation)
    if isempty(equation)
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
    )
end

"""
Processes the input data based in a symbol array equation and returns processed data.
# Arguments
 - `equation::Array{symbol}`: the symbol equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Array{Symbol},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    };
    datanames::Union{Vector{String},Vector{Symbol},Matrix{AbstractString},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    equation = vec(equation)
    equation = Vector{Symbol}(equation)
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
    )
end

"""
Processes the input data based in a symbol vector equation and returns processed data.
# Arguments
 - `equation::Vector{Symbol}`: the symbol vector equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Union{Vector{String}, Vector{Symbol}, Matrix{AbstractString}, Nothing}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Array}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function input(
    equation::Vector{Symbol},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    };
    datanames::Union{Array,Vector{Symbol},Nothing} = nothing,
    method::Union{Symbol,String} = METHOD_DEFAULT,
    intercept::Bool = INTERCEPT_DEFAULT,
    fixedvariables::Union{Nothing,Array} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,String,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    method = Symbol(lowercase(string(method)))
    if method == :precise
        datatype = Float64
    elseif method == :fast
        datatype = Float32
    else
        throw(ArgumentError(INVALID_METHOD))
    end

    if datanames === nothing
        datanames = get_datanames_from_data(data, datanames)
    else
        datanames = Vector{Symbol}(vec(datanames))
    end

    if length(datanames) != size(datanames, 1)
        datanames = Vector{Symbol}(datanames[1, :])
    end

    data = get_data_from_data(data)

    if !ModelSelection.in_vector(equation, datanames)
        msg = string(
            SELECTED_VARIABLES_DOES_NOT_EXISTS,
            ": ",
            equation[(!in).(equation, Ref(datanames))],
        )
        throw(ArgumentError(msg))
    end

    if fixedvariables !== nothing
        fixedvariables = Vector{Symbol}(fixedvariables)
        if !ModelSelection.in_vector(fixedvariables, datanames)
            msg = string(
                SELECTED_FIXED_VARIABLES_DOES_NOT_EXISTS,
                ": ",
                fixedvariables[(!in).(fixedvariables, Ref(datanames))],
            )
            throw(ArgumentError(msg))
        end

        if ModelSelection.in_vector(fixedvariables, equation)
            msg = string(
                SELECTED_FIXED_VARIABLES_IN_EQUATION,
                ": ",
                fixedvariables[(in).(fixedvariables, Ref(equation))],
            )
            throw(ArgumentError(msg))
        end
    end

    if !isa(data, Array{Union{Missing,datatype}}) || !isa(data, Array{Union{datatype}})
        data = Matrix{Union{Missing,datatype}}(data)
    end

    if time !== nothing
        if isa(time, String)
            time = Symbol(time)
        end
        if ModelSelection.get_column_index(time, datanames) === nothing
            msg = string(TIME_VARIABLE_INEXISTENT, ": ", time)
            throw(ArgumentError(msg))
        end

    end

    if panel !== nothing
        if isa(panel, String)
            panel = Symbol(panel)
        end
        if ModelSelection.get_column_index(panel, datanames) === nothing
            msg = string(PANEL_VARIABLE_INEXISTENT, ": ", panel)
            throw(ArgumentError(msg))
        end
    end

    modelselection_data, method, seasonaladjustment, removeoutliers = execute(
        equation,
        data,
        datanames,
        method,
        intercept;
        fixedvariables = fixedvariables,
        panel = panel,
        time = time,
        seasonaladjustment = seasonaladjustment,
        removeoutliers = removeoutliers,
        removemissings = removemissings,
    )

    modelselection_data =
        addextras(modelselection_data, method, seasonaladjustment, removeoutliers)

    return modelselection_data
end

"""
Processes all the inputs parameters and returns processed data.
# Arguments
 - `equation::Vector{Symbol}`: the symbol vector equation.
 - `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}, Tuple, DataFrame, Nothing}`: the input data.
 - `datanames::Vector{Symbol}`: the column names of input data.
 - `method::Union{Symbol, String}`: the data representation based on method fast or precise.
 - `intercept::Bool`: include intercept as a fixed covariate.
 - `fixedvariables::Union{Nothing, Vector{Symbol}}`: TODO add description.
 - `panel::Union{Symbol, String, Nothing}`: panel variable name.
 - `time::Union{Symbol, String, Nothing}`: panel variable name.
 - `seasonaladjustment::Union{Dict, Array, Nothing}`: TODO add description.
 - `removeoutliers::Bool`: TODO add description.
 - `removemissings::Bool`: TODO add description.
"""
function execute(
    equation::Vector{Symbol},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
    },
    datanames::Vector{Symbol},
    method::Symbol,
    intercept::Bool;
    fixedvariables::Union{Nothing,Vector{Symbol}} = FIXED_VARIABLES_DEFAULT,
    panel::Union{Symbol,Nothing} = PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = REMOVEOUTLIERS_DEFAULT,
    removemissings::Bool = REMOVEMISSINGS_DEFAULT,
)
    datatype = method == :precise ? Float64 : Float32
    temp_equation = equation

    if fixedvariables !== nothing
        for fixedvariable in fixedvariables
            if ModelSelection.get_column_index(fixedvariable, temp_equation) === nothing
                temp_equation = vcat(temp_equation, fixedvariable)
            end
        end
    end

    if panel !== nothing &&
       ModelSelection.get_column_index(panel, temp_equation) === nothing
        temp_equation = vcat(temp_equation, panel)
    end

    if time !== nothing && ModelSelection.get_column_index(time, temp_equation) === nothing
        temp_equation = vcat(temp_equation, time)
    end

    (data, datanames) = filter_data_by_selected_columns(data, temp_equation, datanames)
    data = sort_data(data, datanames, panel = panel, time = time)

    panel_data = nothing
    if panel !== nothing
        if validate_panel(data, datanames, panel = panel)
            panel_data = data[:, ModelSelection.get_column_index(panel, datanames)]
        else
            throw(ArgumentError(PANEL_ERROR))
        end
    end

    time_data = nothing
    if time !== nothing
        if validate_time(data, datanames, time = time, panel = panel)
            time_data = data[:, ModelSelection.get_column_index(time, datanames)]
        else
            throw(ArgumentError(TIME_ERROR))
        end
    end

    if seasonaladjustment !== nothing && time !== nothing
        seasonal_adjustments(data, seasonaladjustment, datanames)
    elseif seasonaladjustment !== nothing && time === nothing
        throw(ArgumentError(TIME_VARIABLE_INEXISTENT))
    end

    fixedvariables_data = nothing
    if fixedvariables !== nothing
        cols = []
        for fixedvariable in fixedvariables
            push!(cols, ModelSelection.get_column_index(fixedvariable, datanames))
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
        remove_outliers(data)
    end

    depvar_data = data[1:end, 1]
    expvars_data = data[1:end, 2:end]

    if removemissings
        depvar_data, expvars_data, fixedvariables_data, time_data, panel_data =
            ModelSelection.filter_raw_data_by_empty_values(
                datatype,
                depvar_data,
                expvars_data,
                fixedvariables_data,
                time_data,
                panel_data,
            )
    end

    depvar_data, expvars_data, fixedvariables_data, time_data, panel_data =
        ModelSelection.convert_raw_data(
            datatype,
            depvar_data,
            expvars_data,
            fixedvariables_data,
            time_data,
            panel_data,
        )

    nobs = size(depvar_data, 1)
    modelselection_data = ModelSelection.ModelSelectionData(
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
        removemissings,
        nobs,
    )
    return modelselection_data, method, seasonaladjustment, removeoutliers
end
