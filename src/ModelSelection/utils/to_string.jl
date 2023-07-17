const LINE_LENGTH = 80
const HALF_LINE_LENGTH = Int64(trunc(LINE_LENGTH / 2))


function sprintf_customline(char::String; len::Int = LINE_LENGTH, new_line::Bool = false)
    out = ""
    for i = 1:len
        out *= @sprintf("%s", char)
    end
    if new_line
        out *= sprintf_newline()
    end
    return out
end


function sprintf_doubleline(; len::Int = LINE_LENGTH, new_line::Bool = false)
    return sprintf_customline("═", len = len, new_line = new_line)
end


function sprintf_simpleline(; len::Int = LINE_LENGTH, new_line::Bool = false)
    return sprintf_customline("─", len = len, new_line = new_line)
end


function sprintf_whiteline(; len::Int = LINE_LENGTH, new_line::Bool = false)
    return sprintf_customline(" ", len = len, new_line = new_line)
end


function sprintf_newline(lines = 1)
    out = ""
    for i = 1:lines
        out *= @sprintf("\n")
    end
    return out
end


function sprintf_center(
    text::Union{String,Symbol,Int32,Int64,Float32,Float64};
    len::Int = LINE_LENGTH,
    new_line::Bool = false,
)
    padlen::Int = trunc((len - length(text)) / 2)
    out = ""
    for i = 1:padlen
        out *= @sprintf(" ")
    end
    out *= @sprintf("%s", string(text))
    if new_line
        out *= sprintf_newline()
    end
    return out
end

function sprintf_variable_base(value::String; left_padding::Int = 0, right_padding::Int = 0)
    value = string(value)
    out = ""
    if left_padding > 0
        left_padding = left_padding - length(value)
    end
    for i = 1:left_padding
        out *= @sprintf(" ")
    end
    out *= @sprintf("%s", string(value))
    if right_padding > 0
        right_padding = right_padding - length(value)
    end
    for i = 1:right_padding
        out *= @sprintf(" ")
    end
    return out
end

function sprintf_variable(value::String; left_padding::Int = 0, right_padding::Int = 0)
    return sprintf_variable_base(
        value,
        left_padding = left_padding,
        right_padding = right_padding,
    )
end

function sprintf_variable(value::Symbol; left_padding::Int = 0, right_padding::Int = 0)
    return sprintf_variable_base(
        string(value),
        left_padding = left_padding,
        right_padding = right_padding,
    )
end

function sprintf_variable(
    value::Union{Float32,Float64};
    left_padding::Int = 0,
    right_padding::Int = 0,
)
    return sprintf_variable_base(
        @sprintf("%-10f", value),
        left_padding = left_padding,
        right_padding = right_padding,
    )
end

function sprintf_variable(
    value::Union{Int32,Int64};
    left_padding::Int = 0,
    right_padding::Int = 0,
)
    return sprintf_variable_base(
        @sprintf("%-10d", value),
        left_padding = left_padding,
        right_padding = right_padding,
    )
end

function sprintf_label_values(
    text::Union{String,Symbol},
    values::Union{
        String,
        Array{String},
        Int,
        Array{Int},
        Float32,
        Array{Float32},
        Float64,
        Array{Float64},
    };
    len::Int = HALF_LINE_LENGTH,
    new_line::Bool = false,
)
    if isa(values, String)
        values = [values]
    end
    text = string(text)
    sec_len::Int = trunc(len / length(values))
    out = sprintf_variable(text, right_padding = len)
    for value in values
        out *= sprintf_variable(value, right_padding = sec_len)
    end
    if new_line
        out *= sprintf_newline()
    end
    return out
end


function sprintf_header_block(text::String)
    out = sprintf_newline()
    out *= sprintf_doubleline(new_line = true)
    out *= sprintf_center(text, new_line = true)
    out *= sprintf_doubleline(new_line = true)
    out *= sprintf_newline()
    return out
end


function sprintf_depvar_block(
    data::ModelSelection.ModelSelectionData;
    len = HALF_LINE_LENGTH,
)
    out = sprintf_whiteline(len = len)
    out *= @sprintf("Dependent variable: %s\n", data.depvar)
    out *= sprintf_whiteline(len = len)
    out *= sprintf_simpleline(len = len, new_line = true)
    return out
end


function sprintf_covvar_header(covvars_title, result; len = LINE_LENGTH)
    values = ["Coef."]
    if result.ttest
        values = vcat(values, ["Std.", "t-test"])
    end
    out = sprintf_label_values(covvars_title, values, new_line = true)
    out *= sprintf_simpleline(len = len, new_line = true)
    return out
end


function sprintf_covvar(varname, datanames_index, result, result_data)
    values = [result_data[datanames_index[Symbol(string(varname, "_b"))]]]
    if result.ttest
        values = vcat(
            values,
            [
                result_data[datanames_index[Symbol(string(varname, "_bstd"))]],
                result_data[datanames_index[Symbol(string(varname, "_t"))]],
            ],
        )
    end
    return sprintf_label_values(varname, values, new_line = true)
end


function sprintf_covvars_block(
    covvars_title::String,
    datanames_index::Dict{Symbol,Int64},
    expvars::Vector{Symbol},
    data,
    result,
    result_data,
)
    out = sprintf_covvar_header(covvars_title, result)
    if data.fixedvariables !== nothing
        for varname in data.fixedvariables
            if varname === CONS
                continue
            end
            out *= sprintf_covvar(varname, datanames_index, result, result_data)
        end
    end
    for varname in expvars
        if varname === CONS
            continue
        end
        out *= sprintf_covvar(varname, datanames_index, result, result_data)
    end
    if CONS in data.expvars
        out *= sprintf_covvar(CONS, datanames_index, result, result_data)
    end
    out *= sprintf_newline()
    return out
end

function sprintf_summary_block(
    datanames_index,
    result,
    result_data;
    summary_variables = nothing,
    criteria_variables = nothing,
)
    current_variables = []
    out = ModelSelection.sprintf_simpleline(new_line = true)
    if summary_variables !== nothing
        variables = []
        for (varname, value) in summary_variables
            if !("order" in keys(value))
                value["order"] = 99
            end
            push!(variables, merge(value, Dict("varname" => varname)))
        end
        sort!(variables, lt = (x, y) -> isless(x["order"], y["order"]))
        for variable in variables
            if !(variable["verbose_show"]) || (variable["varname"] in current_variables) || !(variable["varname"] in keys(datanames_index))
                continue
            end
            out *= ModelSelection.sprintf_label_values(
                variable["verbose_title"],
                result_data[datanames_index[variable["varname"]]],
                new_line = true,
            )
            push!(current_variables, variable["varname"])
        end
    end
    if criteria_variables !== nothing
        for (variable, value) in criteria_variables
            if !value["verbose_show"] || variable in current_variables
                continue
            end
            out *= ModelSelection.sprintf_label_values(
                value["verbose_title"],
                result_data[datanames_index[variable]],
                new_line = true,
            )
            push!(current_variables, variable)
        end
    end
    return out
end
