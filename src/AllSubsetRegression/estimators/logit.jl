"""
    logit(
        data::ModelSelectionData;
        outsample::Union{Int64,Vector{Int64},Nothing} = OUTSAMPLE_DEFAULT,
        criteria::Vector{Symbol} = CRITERIA_DEFAULT,
        ztest::Bool = ZTEST_DEFAULT,
        modelavg::Bool = MODELAVG_DEFAULT,
        residualtest::Bool = RESIDUALTEST_DEFAULT,
        orderresults::Bool = ORDERRESULTS_DEFAULT,
    ) -> ModelSelectionData

Perform Logistic Regression (logit) model selection on the on the provided
`ModelSelectionData` using the specified options and returns a new ModelSelectionData object
containing the results.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used
in the model selection process.

# Keyword Arguments
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection. Default: `CRITERIA_DEFAULT`.
- `ztest::Bool`: If `true`, perform z-tests for the coefficient estimates.
   Default: `ZTEST_DEFAULT`.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
   Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.
   Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results based on the selection criteria.
   Default: `ORDERRESULTS_DEFAULT`.

# Returns
- `ModelSelectionData`: The copy of the input `ModelSelectionData` object containing the
logit regression results.

# Example
```julia
result = logit(model_selection_data)
```
"""
function logit(
    data::ModelSelectionData;
    outsample::Union{Nothing,Int,Array} = OUTSAMPLE_DEFAULT,
    criteria::Vector{Symbol} = CRITERIA_DEFAULT,
    ztest::Bool = ZTEST_DEFAULT,
    modelavg::Bool = MODELAVG_DEFAULT,
    residualtest::Bool = RESIDUALTEST_DEFAULT,
    orderresults::Bool = ORDERRESULTS_DEFAULT,
    notify = nothing,
)
    return logit!(
        ModelSelection.copy_modelselectiondata(data),
        outsample = outsample,
        criteria = criteria,
        ztest = ztest,
        modelavg = modelavg,
        residualtest = residualtest,
        orderresults = orderresults,
        notify = notify ,
    )
end

"""
    logit!(
        data::ModelSelectionData;
        outsample::Union{Int64,Vector{Int64},Nothing} = OUTSAMPLE_DEFAULT,
        criteria::Vector{Symbol} = CRITERIA_DEFAULT,
        ztest::Bool = ZTEST_DEFAULT,
        modelavg::Bool = MODELAVG_DEFAULT,
        residualtest::Bool = RESIDUALTEST_DEFAULT,
        orderresults::Bool = ORDERRESULTS_DEFAULT,
    ) -> ModelSelectionData

Perform Logistic Regression (logit) regression analysis on the provided
`ModelSelectionData` using the specified options. This function mutates the input
`ModelSelectionData` object.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used in the model selection process.

# Keyword Arguments
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection. Default: `CRITERIA_DEFAULT`.
- `ztest::Bool`: If `true`, perform z-tests for the coefficient estimates.
   Default: `ZTEST_DEFAULT`.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
   Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.
   Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results based on the selection criteria.
   Default: `ORDERRESULTS_DEFAULT`.

# Returns
- `ModelSelectionData`: The updated input `ModelSelectionData` object containing the logit 
   regression results.

# Example
```julia
result = logit!(model_selection_data)
"""
function logit!(
    data::ModelSelectionData;
    method::Union{Symbol,Nothing} = nothing,
    outsample::Union{Nothing,Int,Array} = OUTSAMPLE_DEFAULT,
    criteria::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    ztest::Bool = ZTEST_DEFAULT,
    modelavg::Bool = MODELAVG_DEFAULT,
    residualtest::Bool = RESIDUALTEST_DEFAULT,
    orderresults::Bool = ORDERRESULTS_DEFAULT,
    notify = nothing,
)
    notification(notify, NOTIFY_MESSAGE, Dict{Symbol,Any}(:estimator => LOGIT), progress=0)
    if method === nothing
        method = ESTIMATORS[LOGIT][METHOD][DEFAULT]
    end
    if criteria === nothing
        criteria = ESTIMATORS[LOGIT][CRITERIA][DEFAULT]
    elseif isa(criteria, Symbol)
        criteria = Vector{Symbol}([criteria])
    end
    validate_criteria(criteria, ESTIMATORS[LOGIT][CRITERIA][AVAILABLE])
    validate_method(method, ESTIMATORS[LOGIT][METHOD][AVAILABLE])
    general_information = ESTIMATORS[LOGIT][GENERAL_INFORMATION]

    result = create_result(
        LOGIT,
        method,
        data,
        outsample,
        criteria,
        modelavg,
        residualtest,
        orderresults,
        general_information,
        ztest = ztest,
    )
    result = logit_execute!(data, result, notify = notify )
    ModelSelection.addresult!(data, result)
    ModelSelection.addresult!(
        data,
        AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY,
        result,
    )
    data = addextras!(data, result)
    return result
end

"""
    logit_execute!(
        data::ModelSelectionData,
        result::AllSubsetRegressionResult
    ) -> AllSubsetRegressionResult

Perform logistic regression model selection analysis for all possible subsets of the
explanatory variables in the given `ModelSelectionData`. This function mutates the input
`AllSubsetRegressionResult` object.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used
   in the model selection process.
- `result::AllSubsetRegressionResult`: The `AllSubsetRegressionResult` object to store the
   results of the OLS regression analysis.

# Returns
- `AllSubsetRegressionResult`: The updated input `AllSubsetRegressionResult` object
   containing the logit regression results for all possible subsets of the explanatory
   variables.

# Example
```julia
logit_execute!(model_selection_data, all_subset_regression_result)
```
"""
function logit_execute!(data::ModelSelectionData, result::AllSubsetRegressionResult; notify = nothing)
    notification(notify, NOTIFY_MESSAGE, Dict{Symbol,Any}(:estimator => LOGIT), progress=5)

    if !data.removemissings
        data = ModelSelection.filter_data_by_empty_values!(data)
    end

    expvars_num = size(data.expvars, 1)
    if data.intercept
        expvars_num = expvars_num - 1
    end

    num_operations = 2^expvars_num - 1
    depvar_data = convert(SharedArray, data.depvar_data)
    expvars_data = convert(SharedArray, data.expvars_data)
    fixedvariables_data = nothing
    if data.fixedvariables_data !== nothing
        fixedvariables_data = convert(SharedArray, data.fixedvariables_data)
    end
    panel_data = nothing
    if data.panel_data !== nothing
        panel_data = convert(SharedArray, data.panel_data)
    end
    time_data = nothing
    if data.time_data !== nothing
        time_data = convert(SharedArray, data.time_data)
    end
    result_data = fill!(SharedArray{data.datatype}(num_operations, size(result.datanames, 1)), NaN)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)
    
    panel_values = nothing
    if data.panel !== nothing
        panel_values = unique(data.panel_data)
    end
    depvar_without_outsample_subset, expvars_without_outsample_subset, fixedvariables_without_outsample_subset, panel_without_outsample_subset = get_insample_subset(
        depvar_data,
        expvars_data,
        fixedvariables_data,
        panel_data,
        result.outsample,
        collect(1:size(expvars_data, 2)),
    )
    fullexpvars_without_outsample_subset = expvars_without_outsample_subset
    if fixedvariables_without_outsample_subset !== nothing
        fullexpvars_without_outsample_subset = hcat(expvars_without_outsample_subset, fixedvariables_without_outsample_subset)
    end
    if panel_values !== nothing && panel_without_outsample_subset !== nothing
        panel_subset_vars = Matrix{Int64}(zeros(size(panel_without_outsample_subset, 1), size(panel_values, 1)))
        for (i, value) in enumerate(panel_values)
            panel_subset_vars[:, i] = panel_without_outsample_subset[:] .== value
        end
        fullexpvars_without_outsample_subset = hcat(fullexpvars_without_outsample_subset, panel_subset_vars)
    end
    notification(notify, NOTIFY_MESSAGE, Dict{Symbol,Any}(:estimator => LOGIT), progress=15)
    gum_model = GLM.fit(
        GeneralizedLinearModel,
        fullexpvars_without_outsample_subset,
        depvar_without_outsample_subset,
        Binomial(),
        LogitLink(),
        start = zeros(size(fullexpvars_without_outsample_subset, 2)),
    )
    start_coef = coeftable(gum_model).cols[1] # FIXME: Convert to datatype

    notification(notify, NOTIFY_MESSAGE, Dict{Symbol,Any}(:estimator => LOGIT), progress=25)
    if nprocs() == nworkers()
        for order = 1:num_operations
            logit_execute_row!(
                order,
                data.depvar,
                data.expvars,
                data.fixedvariables,
                data.panel,
                data.time,
                start_coef,
                datanames_index,
                depvar_data,
                expvars_data,
                fixedvariables_data,
                panel_data,
                time_data,
                result_data,
                panel_values,
                data.intercept,
                data.datatype,
                result.outsample,
                result.criteria,
                result.ztest,
                result.residualtest,
            )
        end
    else
        ops_per_worker = div(num_operations, nworkers())
        if (nworkers() > num_operations)
            num_jobs = num_operations
        else
            num_jobs = nworkers()
        end
        jobs = []
        for num_job = 1:num_jobs
            push!(
                jobs,
                @spawnat num_job + 1 logit_execute_job!(
                    num_job,
                    num_jobs,
                    ops_per_worker,
                    data.depvar,
                    data.expvars,
                    data.fixedvariables,
                    data.panel,
                    data.time,
                    start_coef,
                    datanames_index,
                    depvar_data,
                    expvars_data,
                    fixedvariables_data,
                    panel_data,
                    time_data,
                    result_data,
                    panel_values,
                    data.intercept,
                    data.datatype,
                    result.outsample,
                    result.criteria,
                    result.ztest,
                    result.residualtest,
                )
            )
        end
        for job in jobs
            fetch(job)
        end

        remainder = num_operations - ops_per_worker * num_jobs
        if remainder > 0
            for j = 1:remainder
                order = j + ops_per_worker * num_jobs
                logit_execute_row!(
                    order,
                    data.depvar,
                    data.expvars,
                    data.fixedvariables,
                    data.panel,
                    data.time,
                    start_coef,
                    datanames_index,
                    depvar_data,
                    expvars_data,
                    fixedvariables_data,
                    panel_data,
                    time_data,
                    result_data,
                    panel_values,
                    data.intercept,
                    data.datatype,
                    result.outsample,
                    result.criteria,
                    result.ztest,
                    result.residualtest,
                )
            end
        end
    end
    notification(notify, NOTIFY_MESSAGE, Dict{Symbol,Any}(:estimator => LOGIT), progress=75)

    result.data = Array(result_data)

    len_criteria = length(result.criteria)
    for criteria in result.criteria
        result.data[:, datanames_index[:order]] +=
            AVAILABLE_CRITERIA[criteria]["index"] *
            (1 / len_criteria) *
            (
                (
                    result.data[:, datanames_index[criteria]] .-
                    mean(result.data[:, datanames_index[criteria]])
                ) ./ std(result.data[:, datanames_index[criteria]])
            )
    end

    # FIXME: modelavg
    # if result.modelavg
    # 	delta = maximum(result.data[:, datanames_index[:order]]) .- result.data[:, datanames_index[:order]]
    # 	w1 = exp.(-delta / 2)
    # 	result.data[:, datanames_index[:weight]] = w1 ./ sum(w1)
    # 	result.modelavg_data = Vector{Float64}(undef, size(result.datanames))
    # 	weight_pos = (result.ztest) ? 4 : 2
    # 	for expvar in data.expvars
    # 		obs = result.data[:, datanames_index[Symbol(string(expvar, "_b"))]]
    # 		if result.ztest
    # 			obs = hcat(obs, result.data[:, datanames_index[Symbol(string(expvar, "_bstd"))]])
    # 			obs = hcat(obs, result.data[:, datanames_index[Symbol(string(expvar, "_z"))]])
    # 		end
    # 		obs = hcat(obs, result.data[:, datanames_index[:weight]])
    # 
    # 		obs = obs[findall(x -> !isnan(obs[x, 1]), 1:size(obs, 1)), :]
    # 		obs[:, weight_pos] /= sum(obs[:, weight_pos])
    # 
    # 		result.modelavg_data[datanames_index[Symbol(string(expvar, "_b"))]] = sum(obs[:, 1] .* obs[:, weight_pos])
    # 		if result.ztest
    # 			result.modelavg_data[datanames_index[Symbol(string(expvar, "_bstd"))]] = sum(obs[:, 2] .* obs[:, weight_pos])
    # 			result.modelavg_data[datanames_index[Symbol(string(expvar, "_z"))]] = sum(obs[:, 3] .* obs[:, weight_pos])
    # 		end
    # 	end
    # 
    # 	for criteria in [:nobs, :r2adj, :F, :order]
    # 		if criteria in keys(datanames_index)
    # 			result.modelavg_data[datanames_index[criteria]] = sum(result.data[:, datanames_index[criteria]] .* result.data[:, datanames_index[:weight]])
    # 		end
    # 	end
    # end

    if result.orderresults
        result.data = sortrows(result.data, [datanames_index[:order]]; rev = true)
        result.bestresult_data = result.data[1, :]
    else
        max_order = result.data[1, datanames_index[:order]]
        best_result_index = 1
        for i = 1:num_operations
            if result.data[i, datanames_index[:order]] > max_order
                max_order = result.data[i, datanames_index[:order]]
                best_result_index = i
            end
        end
        result.bestresult_data = result.data[best_result_index, :]
    end

    result.nobs = result.bestresult_data[datanames_index[:nobs]]
    notification(notify, NOTIFY_MESSAGE, Dict{Symbol,Any}(:estimator => LOGIT), progress=100)

    return result
end

"""
# TODO: typing and example
    logit_execute_job!(
        num_job::Int64,
        num_jobs::Int64,
        ops_per_worker::Int64,
        depvar::Symbol,
        expvars::Vector{Symbol},
        fixedvariables::Union{Vector{Symbol},Nothing},
        start_coef::Vector{Float64},
        datanames_index::Dict{Symbol, Int64},
        depvar_data::Union{SharedArray{Float32},SharedArray{Float64}},
        expvars_data::Union{SharedArray{Float32},SharedArray{Float64}},
        fixedvariables_data::Union{SharedArray{Float32},SharedArray{Float64},Nothing},
        result_data::Union{SharedArray{Float32},SharedArray{Float64}},
        intercept::Bool,
        time::Union{Symbol,Nothing},
        datatype::DataType,
        outsample::Union{Int64,Vector{Int64},Nothing},
        criteria::Vector{Symbol},
        ztest::Bool,
        residualtest::Bool,
    )

Execute a single job in the logit procedure. This function is called by the main
`logit_execute!` function to parallelize the model estimation across multiple workers.
This function is intended for use with multi-core parallel processing.

# Parameters
- `num_job::Int64`: The unique identifier for the current job.
- `num_jobs::Int64`: The total number of jobs to be executed.
- `ops_per_worker::Int64`: The number of operations per worker.
- `depvar::Symbol`: The dependent variable in the regression model.
- `expvars::Vector{Symbol}`: The explanatory variables in the regression model.
- `fixedvariables::Union{Vector{Symbol},Nothing}`: The fixed variables in the regression
   model.
- `start_coef`: The starting coefficients.
- `datanames_index::Dict{Symbol, Int64}`: A dictionary that maps variable names to their
   corresponding column indices in the result_data array.
- `depvar_data::Union{SharedArray{Float32},SharedArray{Float64}}`: The data for the
   dependent variable.
- `expvars_data::Union{SharedArray{Float32},SharedArray{Float64}}`: The data for the
   explanatory variables.
- `fixedvariables_data::Union{SharedArray{Float32},SharedArray{Float64},Nothing}`: The data
   for the fixed variables, or `nothing` if no fixed variables are present.
- `result_data::Union{SharedArray{Float32},SharedArray{Float64}}`: The data for storing the
   results of the OLS regression analyses.
- `intercept::Bool`: Whether the regression model should include an intercept term.
- `time::Union{Symbol,Nothing}`: The time variable in the regression model.
- `datatype::DataType`: Specifies the type of the result data (e.g., Float32 or Float64).
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection. Default: `CRITERIA_DEFAULT`.
- `ztest::Bool`: If `true`, perform z-tests for the coefficient estimates.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models

# Returns
This function does not return any value. It modifies the `result_data` SharedArray in-place.

# Example
```julia
logit_execute_job!(
    num_job,
    num_jobs,
    ops_per_worker,
    depvar,
    expvars,
    fixedvariables,
    start_coef,
    datanames_index,
    depvar_data,
    expvars_data,
    fixedvariables_data,
    result_data,
    intercept,
    time,
    datatype,
    outsample,
    criteria,
    ztest,
    residualtest
)
```
"""
function logit_execute_job!(
    num_job::Int64,
    num_jobs::Int64,
    ops_per_worker::Int64,
    depvar::Symbol,
    expvars::Vector{Symbol},
    fixedvariables::Union{Vector{Symbol},Nothing},
    panel::Union{Symbol,Nothing},
    time::Union{Symbol,Nothing},
    start_coef::Vector{Float64},
    datanames_index::Dict{Symbol,Int64},
    depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    panel_data::Union{SharedArray{Int64},SharedArray{Int32},SharedArray{Int16},Nothing},
    time_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    panel_values::Union{Vector{Int64},Vector{Int32},Vector{Int16},Nothing},
    intercept::Bool,
    datatype::DataType,
    outsample::Union{Int64,Vector{Int64},Nothing},
    criteria::Vector{Symbol},
    ztest::Bool,
    residualtest::Bool,
)
    for j = 1:ops_per_worker
        order = (j - 1) * num_jobs + num_job
        logit_execute_row!(
            order,
            depvar,
            expvars,
            fixedvariables,
            panel,
            time,
            start_coef,
            datanames_index,
            depvar_data,
            expvars_data,
            fixedvariables_data,
            panel_data,
            time_data,
            result_data,
            panel_values,
            intercept,
            datatype,
            outsample,
            criteria,
            ztest,
            residualtest,
            num_jobs = num_jobs,
            num_job = num_job,
            iteration_num = j,
        )
    end
end

"""
    logit_execute_row!(
        order::Int64,
        depvar::Symbol,
        expvars::Vector{Symbol},
        fixedvariables::Union{Vector{Symbol},Nothing},
        start_coef::Vector{Float64},
        datanames_index::Dict{Symbol, Int64},
        depvar_data::Union{SharedArray{Float32},SharedArray{Float64}},
        expvars_data::Union{SharedArray{Float32},SharedArray{Float64}},
        fixedvariables_data::Union{SharedArray{Float32},SharedArray{Float64},Nothing},
        result_data::Union{SharedArray{Float32},SharedArray{Float64}},
        intercept::Bool,
        time::Union{Symbol,Nothing},
        datatype::DataType,
        outsample::Union{Int64,Vector{Int64},Nothing},
        criteria::Vector{Symbol},
        ztest::Bool,
        residualtest::Bool;
        num_jobs::Union{Int64,Nothing} = nothing,
        num_job::Union{Int64,Nothing} = nothing,
        iteration_num::Union{Int64,Nothing} = nothing,
    )

Perform OLS estimation for a specific order (i.e., a particular combination of independent
variables) and store the results in a pre-allocated SharedArray. This implementation
supports out-of-sample testing, z-tests, and residual tests.

# Parameters
- `order::Int64`: The order of the model (i.e., the specific combination of independent
   variables to be considered).
- `depvar::Symbol`: The dependent variable in the regression model.
- `expvars::Vector{Symbol}`: The explanatory variables in the regression model.
- `fixedvariables::Union{Vector{Symbol},Nothing}`: The fixed variables in the regression
   model.
- `start_coef`: The starting coefficients.
- `datanames_index::Dict{Symbol, Int64}`: The index for data names.
- `depvar_data::Union{SharedArray{Float32},SharedArray{Float64}}`: The data for the
   dependent variable.
- `expvars_data::Union{SharedArray{Float32},SharedArray{Float64}}`: The data for the
   explanatory variables.
- `fixedvariables_data::Union{SharedArray{Float32},SharedArray{Float64},Nothing}`: The data
   for the fixed variables, or `nothing` if no fixed variables are present.
- `result_data::Union{SharedArray{Float32},SharedArray{Float64}}`: A pre-allocated
   SharedArray to store the results of the OLS estimation.
- `intercept::Bool`: Whether the regression model should include an intercept term.
- `time::Union{Symbol,Nothing}`: The time variable in the regression model.
- `datatype::DataType`: Specifies the type of the result data (e.g., Float32 or Float64).
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired.
- `criteria`: A vector of symbols representing the information criteria to be calculated
   (e.g., AIC, BIC, etc.).
- `ztest::Bool`: If `true`, perform z-tests for the coefficient estimates.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.

# Optional Keyword Arguments
- `num_job::Union{Int64,Nothing}`: The unique identifier for the current job.
- `num_jobs::Union{Int64,Nothing}`: The total number of jobs to be executed.
- `iteration_num::Union{Int64,Nothing}`: The iteration number.

# Returns
This function does not return any value. It modifies the `result_data` SharedArray in-place.

# Example
```julia
logit_execute_row!(
    order,
    depvar,
    expvars,
    fixedvariables,
    start_coef,
    depvar_data,
    fixedvariables,
    datanames_index,
    depvar_data,
    expvars_data,
    fixedvariables_data,
    result_data,
    intercept,
    time,
    datatype,
    outsample,
    criteria,
    ztest,
    residualtest
)
```
"""
function logit_execute_row!(
    order::Int64,
    depvar::Symbol,
    expvars::Vector{Symbol},
    fixedvariables::Union{Vector{Symbol},Nothing},
    panel::Union{Symbol,Nothing},
    time::Union{Symbol,Nothing},
    start_coef::Vector{Float64},
    datanames_index::Dict{Symbol,Int64},
    depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    panel_data::Union{SharedArray{Int64},SharedArray{Int32},SharedArray{Int16},Nothing},
    time_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    panel_values::Union{Vector{Int64},Vector{Int32},Vector{Int16},Nothing},
    intercept::Bool,
    datatype::DataType,
    outsample::Union{Int64,Vector{Int64},Nothing},
    criteria::Vector{Symbol},
    ztest::Bool,
    residualtest::Bool;
    num_jobs::Union{Int64,Nothing} = nothing,
    num_job::Union{Int64,Nothing} = nothing,
    iteration_num::Union{Int64,Nothing} = nothing,
)
    selected_variables_index = ModelSelection.get_selected_variables(order, expvars, intercept)
    depvar_subset, expvars_subset, fixedvariables_subset, panel_subset = get_insample_subset(
        depvar_data,
        expvars_data,
        fixedvariables_data,
        panel_data,
        outsample,
        selected_variables_index,
    )
    outsample_enabled = size(depvar_subset, 1) < size(depvar_data, 1)

    fullexpvars_subset = expvars_subset
    coef_index = copy(selected_variables_index)
    if fixedvariables_subset !== nothing
        fullexpvars_subset = hcat(fullexpvars_subset, fixedvariables_subset)
        expvars_subset_size = size(expvars_subset, 2)
        for (index, fixedvariable) in enumerate(fixedvariables)
            append!(coef_index, expvars_subset_size + index)
        end
    end

    if panel_values !== nothing && panel_subset !== nothing
        panel_subset_vars = Matrix{Int64}(zeros(size(panel_subset, 1), size(panel_values, 1)))
        for (i, value) in enumerate(panel_values)
            panel_subset_vars[:, i] = panel_subset[:] .== value
        end
        fullexpvars_subset = hcat(fullexpvars_subset, panel_subset_vars)
        panel_subset_vars_size = size(panel_subset_vars, 2)
        for (index, panel_value) in enumerate(panel_values)
            append!(coef_index, panel_subset_vars_size + index)
        end
    end

    nobs = size(depvar_subset, 1)
    ncoef = size(fullexpvars_subset, 2)

    start_coef_subset = start_coef[coef_index]

    model = GLM.fit(
        GeneralizedLinearModel,
        fullexpvars_subset,
        depvar_subset,
        Binomial(),
        LogitLink(),
        start = start_coef_subset,
    )
    b = coef(model)
    #ŷ = predict(model)
    er2 = model.rr.devresid                  # model.rr.devresid #squared errors
    er=er2 .^ (0.5)
    sse = sum(er2)                           # deviance residual sum of squares
    df_e = nobs - ncoef                     # degrees of freedom	
    rmse = sqrt(sse / nobs)                  # root mean squared error using deviance residuals
    null_dev = nulldeviance(model)
    r2 = 1 - (sse/null_dev)                  # model Pseudo R-squared
    r2adj = 1-(1-r2)*((nobs-1)/(df_e)) # adjusted R-squared
    ll = GLM.loglikelihood(model)
    lln= GLM.nullloglikelihood(model)
    LR = 2*(ll-lln)                      # Likelihood ratio test


    if ztest
        bstd = stderror(model)
    end
    
    if outsample_enabled > 0
        depvar_outsample_subset, expvars_outsample_subset, fixedvariables_outsample_subset, panel_outsample_subset =
            get_outsample_subset(
                depvar_data,
                expvars_data,
                fixedvariables_data,
                panel_data,
                outsample,
                selected_variables_index,
            )
        fullexpvars_outsample_subset = expvars_outsample_subset
        if fixedvariables_outsample_subset !== nothing
            fullexpvars_outsample_subset = hcat(fullexpvars_outsample_subset, fixedvariables_outsample_subset)
        end
        if panel_outsample_subset !== nothing
            panel_subset_vars = Matrix{Int64}(zeros(size(panel_outsample_subset, 1), size(panel_values, 1)))
            for (i, value) in enumerate(panel_values)
                panel_subset_vars[:, i] = panel_outsample_subset[:] .== value
            end
            fullexpvars_outsample_subset = hcat(fullexpvars_outsample_subset, panel_subset_vars)
        end

        # out-of-sample residuals
        prob = exp.(fullexpvars_outsample_subset * model.pp.beta0) ./ (1 .+ exp.(fullexpvars_outsample_subset * model.pp.beta0))
        erout = (sign.(-0.5 .+ depvar_outsample_subset)) .* sqrt.(-2 .* (depvar_outsample_subset .* log.(prob) .+ (1 .- depvar_outsample_subset) .* log.(1 .- prob)))
        
        # residual sum of squares
        sseout = sum(erout .^ 2)
        outsample_count = outsample
        if (isa(outsample, Array))
            outsample_count = size(outsample, 1)
        end
        # root mean squared error
        rmseout = sqrt(sseout / outsample_count)
        result_data[order, datanames_index[:rmseout]] = rmseout
    end


    result_data[order, datanames_index[:index]] = order
    for (index, selected_variable_index) in enumerate(selected_variables_index)
        result_data[
            order,
            datanames_index[Symbol(string(expvars[selected_variable_index], "_b"))],
        ] = datatype(b[index])
        if ztest
            result_data[
                order,
                datanames_index[Symbol(string(expvars[selected_variable_index], "_bstd"))],
            ] = datatype(bstd[index])
            result_data[
                order,
                datanames_index[Symbol(string(expvars[selected_variable_index], "_z"))],
            ] =
                result_data[
                    order,
                    datanames_index[Symbol(string(expvars[selected_variable_index], "_b"))],
                ] / result_data[
                    order,
                    datanames_index[Symbol(
                        string(expvars[selected_variable_index], "_bstd"),
                    )],
                ]
        end
    end

    result_data[order, datanames_index[:nobs]] = Int64(round(nobs)) 
    result_data[order, datanames_index[:ncoef]] = ncoef  
    result_data[order, datanames_index[:sse]] = datatype(sse) 
    result_data[order, datanames_index[:r2]] = datatype(r2) 
    result_data[order, datanames_index[:rmse]] = datatype(rmse) 
    result_data[order, datanames_index[:order]] = 0 #chequear
    result_data[order, datanames_index[:r2adj]] = datatype(r2adj) 
    result_data[order, datanames_index[:LR]] = datatype(LR) 

    if :aic in criteria || :aicc in criteria
        aic = GLM.aic(model)  # FIXME: Sort by AIC
    end

    if :aic in criteria
        result_data[order, datanames_index[:aic]] = aic
    end

    if :aicc in criteria
        result_data[order, datanames_index[:aicc]] = GLM.aicc(model)
    end

    if :bic in criteria
        result_data[order, datanames_index[:bic]] = GLM.bic(model)
    end

    if residualtest
        x = er
        n = length(x)
        m1 = sum(x) / n
        m2 = sum((x .- m1) .^ 2) / n
        m3 = sum((x .- m1) .^ 3) / n
        m4 = sum((x .- m1) .^ 4) / n
        b1 = (m3 / m2^(3 / 2))^2
        b2 = (m4 / m2^2)
        statistic = n * b1 / 6 + n * (b2 - 3)^2 / 24
        d = Chisq(2.0)
        jbtest = 1 .- cdf(d, statistic)
        # there is controversy about the normality assumption for nonlinear models.

        xb_predict = model.rr.eta
        interactions = xb_predict .* fullexpvars_subset
        fullexpvars_with_interactions = hcat(fullexpvars_subset, interactions)
        model_het = GLM.fit(
            GeneralizedLinearModel,
            fullexpvars_with_interactions,
            depvar_subset,
            Binomial(),
            LogitLink(),
        )
        ll2= GLM.loglikelihood(model_het)
        statisticw = 2*(ll2-ll)
        wtest = ccdf(Chisq(ncoef), statisticw)    
        # we use a LR test  for heteroskedasticity as a variation of the Wooldridge (2010) LM test.       
        
        result_data[order, datanames_index[:wtest]] = wtest
        result_data[order, datanames_index[:jbtest]] = jbtest

        if time !== nothing
            er_mean = mean(er)
            x = [i < er_mean ? 0 : 1 for i in er]
            n = length(x)
            nabove = sum(x)
            nbelow = n - nabove
            
            # Get the expected value and standard deviation
            μ = 1 + 2 * nabove * (nbelow / n)
            σ = sqrt((μ - 1) * (μ - 2) / (n - 1))
        
            # Get the number of runs
            nruns = 1
            for k in 1:(n - 1)
                @inbounds if x[k] != x[k + 1]
                    nruns += 1
                end
            end
        
            # calculate simple z-statistic
            z = (nruns - μ) / σ
            wwtest = ccdf(Normal(), z) ## probaremos con un 
            result_data[order, datanames_index[:wwtest]] = wwtest
        end
    end
end
