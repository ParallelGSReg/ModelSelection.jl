"""
    ols!(
        data::ModelSelectionData;
        outsample::Union{Int64,Vector{Int64},Nothing} = OUTSAMPLE_DEFAULT,
        criteria::Vector{Symbol} = CRITERIA_DEFAULT,
        ttest::Bool = TTEST_DEFAULT,
        modelavg::Bool = MODELAVG_DEFAULT,
        residualtest::Bool = RESIDUALTEST_DEFAULT,
        orderresults::Bool = ORDERRESULTS_DEFAULT,
    ) -> ModelSelectionData

Perform Ordinary Least Squares (OLS) regression analysis on the provided
`ModelSelectionData` using the specified options. This function mutates the input
`ModelSelectionData` object.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used
   in the model selection process.

# Keyword Arguments
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection. Default: `CRITERIA_DEFAULT`.
- `ttest::Bool`: If `true`, perform t-tests for the coefficient estimates.
   Default: `TTEST_DEFAULT`.
- `modelavg::Bool`: If `true`, perform model averaging using the selected models.
   Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.
   Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results based on the selection criteria.
   Default: `ORDERRESULTS_DEFAULT`.

# Returns
- `ModelSelectionData`: The updated input `ModelSelectionData` object containing the OLS
   regression results.

# Example
```julia
updated_data = ols!(model_selection_data)
```
"""
function ols!(
    data::ModelSelectionData;
    method::Union{Symbol,Nothing} = nothing,
    outsample::Union{Int64,Vector{Int64},Nothing} = OUTSAMPLE_DEFAULT,
    criteria::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    ttest::Bool = TTEST_DEFAULT,
    modelavg::Bool = MODELAVG_DEFAULT,
    residualtest::Bool = RESIDUALTEST_DEFAULT,
    orderresults::Bool = ORDERRESULTS_DEFAULT,
    notify = nothing
)
    ModelSelection.notification(notify, "Performing All Subset Regression", Dict(:estimator => :ols, :progress => 0))
    if method === nothing
        method = ESTIMATORS[OLS][METHOD][DEFAULT]
    end
    if criteria === nothing
        criteria = ESTIMATORS[OLS][CRITERIA][DEFAULT]
    elseif isa(criteria, Symbol)
        criteria = Vector{Symbol}([criteria])
    end
    
    if outsample === nothing
        outsample = OUTSAMPLE_DEFAULT
    end
    validate_criteria(criteria, ESTIMATORS[OLS][CRITERIA][AVAILABLE])
    validate_method(method, ESTIMATORS[OLS][METHOD][AVAILABLE])
    validate_dataset(data, outsample)

    general_information = ESTIMATORS[OLS][GENERAL_INFORMATION]
    result = create_result(
        :ols,
        method,
        data,
        outsample,
        criteria,
        modelavg,
        residualtest,
        orderresults,
        general_information,
        ttest = ttest,
    )
    result = ols_execute!(data, result, notify=notify)
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
    ols_execute!(
        data::ModelSelectionData,
        result::AllSubsetRegressionResult
    ) -> AllSubsetRegressionResult

Perform Ordinary Least Squares (OLS) regression analysis for all possible subsets of the
explanatory variables in the given `ModelSelectionData`. This function mutates the input
`AllSubsetRegressionResult` object.

# Parameters
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used
   in the model selection process.
- `result::AllSubsetRegressionResult`: The `AllSubsetRegressionResult` object to store the
   results of the OLS regression analysis.

# Returns
- `AllSubsetRegressionResult`: The updated input `AllSubsetRegressionResult` object
   containing the OLS regression results for all possible subsets of the explanatory
   variables.

# Example
```julia
ols_execute!(model_selection_data, all_subset_regression_result)
```
"""
function ols_execute!(data::ModelSelectionData, result::AllSubsetRegressionResult; notify = nothing)
    ModelSelection.notification(notify, "Performing All Subset Regression", Dict(:estimator => :ols, :progress => 5))

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
    ModelSelection.notification(notify, "Performing All Subset Regression", Dict(:estimator => :ols, :progress => 25))
    
    panel_values = nothing
    if data.panel !== nothing
        panel_values = unique(data.panel_data)
    end
    
    if nprocs() == nworkers()
        for order = 1:num_operations
            ols_execute_row!(
                order,
                data.depvar,
                data.expvars,
                data.fixedvariables,
                data.panel,
                data.time,
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
                result.method,
                result.outsample,
                result.criteria,
                result.ttest,
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
                @spawnat num_job + 1 ols_execute_job!(
                    num_job,
                    num_jobs,
                    ops_per_worker,
                    data.depvar,
                    data.expvars,
                    data.fixedvariables,
                    data.panel,
                    data.time,
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
                    result.method,
                    result.outsample,
                    result.criteria,
                    result.ttest,
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
                ols_execute_row!(
                    order,
                    data.depvar,
                    data.expvars,
                    data.fixedvariables,
                    data.panel,
                    data.time,
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
                    result.method,
                    result.outsample,
                    result.criteria,
                    result.ttest,
                    result.residualtest,
                )
            end
        end
    end

    result.data = Array(result_data)

    if :cp in result.criteria
        result.data[:, datanames_index[:cp]] =
            (
                result.data[:, datanames_index[:nobs]] .-
                maximum(result.data[:, datanames_index[:ncoef]]) .- 2
            ) .* (
                result.data[:, datanames_index[:rmse]] ./
                minimum(result.data[:, datanames_index[:rmse]])
            ) .- (
                result.data[:, datanames_index[:nobs]] .-
                2 .* result.data[:, datanames_index[:ncoef]]
            )
    end

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
    ModelSelection.notification(notify, "Performing All Subset Regression", Dict(:estimator => :ols, :progress => 75))
    if result.modelavg
        delta =
            maximum(result.data[:, datanames_index[:order]]) .-
            result.data[:, datanames_index[:order]]
        w1 = exp.(-delta / 2)
        result.data[:, datanames_index[:weight]] = w1 ./ sum(w1)
        result.modelavg_data = Vector{Union{Int64,data.datatype}}(undef, size(result.datanames))
        weight_pos = (result.ttest) ? 4 : 2
        for expvar in data.expvars
            obs = result.data[:, datanames_index[Symbol(string(expvar, "_b"))]]
            if result.ttest
                obs = hcat(
                    obs,
                    result.data[:, datanames_index[Symbol(string(expvar, "_bstd"))]],
                )
                obs =
                    hcat(obs, result.data[:, datanames_index[Symbol(string(expvar, "_t"))]])
            end
            obs = hcat(obs, result.data[:, datanames_index[:weight]])

            obs = obs[findall(x -> !isnan(obs[x, 1]), 1:size(obs, 1)), :]
            obs[:, weight_pos] /= sum(obs[:, weight_pos])

            result.modelavg_data[datanames_index[Symbol(string(expvar, "_b"))]] =
                sum(obs[:, 1] .* obs[:, weight_pos])
            if result.ttest
                result.modelavg_data[datanames_index[Symbol(string(expvar, "_bstd"))]] =
                    sum(obs[:, 2] .* obs[:, weight_pos])
                result.modelavg_data[datanames_index[Symbol(string(expvar, "_t"))]] =
                    sum(obs[:, 3] .* obs[:, weight_pos])
            end
        end

        for criteria in [:nobs, :r2adj, :F, :order]
            if criteria in keys(datanames_index)
                result.modelavg_data[datanames_index[criteria]] = sum(
                    result.data[:, datanames_index[criteria]] .*
                    result.data[:, datanames_index[:weight]],
                )
            end
        end
        result.modelavg_data[datanames_index[:nobs]] = Int64(round(result.modelavg_data[datanames_index[:nobs]]))
    end

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
    result.bestresult_data[datanames_index[:nobs]] =
        Int64(round(result.bestresult_data[datanames_index[:nobs]]))
    result.nobs = result.bestresult_data[datanames_index[:nobs]]
    ModelSelection.notification(notify, "Performing All Subset Regression", Dict(:estimator => :ols, :progress => 100))
    return result
end

"""
    ols_execute_job!(
        num_job::Int64,
        num_jobs::Int64,
        ops_per_worker::Int64,
        depvar::Symbol,
        expvars::Vector{Symbol},
        fixedvariables::Union{Vector{Symbol},Nothing},
        datanames_index::Dict{Symbol, Int64},
        depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
        expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
        fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
        result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
        intercept::Bool,
        time::Union{Symbol,Nothing},
        datatype::DataType,
        outsample::Union{Int64,Vector{Int64},Nothing},
        criteria::Vector{Symbol},
        ttest::Bool,
        residualtest::Bool,
    )

Execute a single job in the OLS procedure. This function is called by the main
`ols_execute!` function to parallelize the model estimation across multiple workers.
This function is intended for use with multi-core parallel processing.

# Parameters
- `num_job::Int64`: The unique identifier for the current job.
- `num_jobs::Int64`: The total number of jobs to be executed.
- `ops_per_worker::Int64`: The number of operations per worker.
- `depvar::Symbol`: The dependent variable in the regression model.
- `expvars::Vector{Symbol}`: The explanatory variables in the regression model.
- `fixedvariables::Union{Vector{Symbol},Nothing}`: The fixed variables in the regression
   model.
- `datanames_index::Dict{Symbol, Int64}`: A dictionary that maps variable names to their
   corresponding column indices in the result_data array.
- `depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}}`: The data for the
   dependent variable.
- `expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}}`: The data for the
   explanatory variables.
- `fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing}`: The data
   for the fixed variables, or `nothing` if no fixed variables are present.
- `result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}}`: The data for storing the
   results of the OLS regression analyses.
- `intercept::Bool`: Whether the regression model should include an intercept term.
- `time::Union{Symbol,Nothing}`: The time variable in the regression model.
- `datatype::DataType`: Specifies the type of the result data (e.g., Float32 or Float64).
- `method`: A symbol indicating the desired estimation method. Can be either `:fast` for a
   faster but less precise estimation, or `:precise` for a slower but more accurate
   estimation (default).
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired.
- `criteria::Vector{Symbol}`: The selection criteria symbols to be used for model comparison
   and selection. Default: `CRITERIA_DEFAULT`.
- `ttest::Bool`: If `true`, perform t-tests for the coefficient estimates.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.

# Returns
This function does not return any value. It modifies the `result_data` SharedArray in-place.

# Example
```julia
ols_execute_job!(
    num_job,
    num_jobs,
    ops_per_worker,
    depvar,
    expvars,
    fixedvariables,
    datanames_index,
    depvar_data,
    expvars_data,
    fixedvariables_data,
    result_data,
    intercept,
    time,
    datatype,
    method,
    outsample,
    criteria,
    ttest,
    residualtest
)
```
"""
function ols_execute_job!(
    num_job::Int64,
    num_jobs::Int64,
    ops_per_worker::Int64,
    depvar::Symbol,
    expvars::Vector{Symbol},
    fixedvariables::Union{Vector{Symbol},Nothing},
    panel::Union{Symbol,Nothing},
    time::Union{Symbol,Nothing},
    datanames_index::Dict{Symbol,Int64},
    depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    panel_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    time_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    panel_values::Union{Vector{Float64},Vector{Float32},Vector{Float16},Nothing},
    intercept::Bool,
    datatype::DataType,
    method::Symbol,
    outsample::Union{Int64,Vector{Int64},Nothing},
    criteria::Vector{Symbol},
    ttest::Bool,
    residualtest::Bool,
)
    for j = 1:ops_per_worker
        order = (j - 1) * num_jobs + num_job
        ols_execute_row!(
            order,
            depvar,
            expvars,
            fixedvariables,
            panel,
            time,
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
            method,
            outsample,
            criteria,
            ttest,
            residualtest,
            num_jobs = num_jobs,
            num_job = num_job,
            iteration_num = j,
        )
    end
end

"""
    ols_execute_row!(
        order::Int64,
        depvar::Symbol,
        expvars::Vector{Symbol},
        fixedvariables::Union{Vector{Symbol},Nothing},
        datanames_index::Dict{Symbol, Int64},
        depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
        expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
        fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
        result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
        intercept::Bool,
        time::Union{Symbol,Nothing},
        datatype::DataType,
        outsample::Union{Int64,Vector{Int64},Nothing},
        criteria::Vector{Symbol},
        ttest::Bool,
        residualtest::Bool;
        num_jobs::Union{Int64,Nothing} = nothing,
        num_job::Union{Int64,Nothing} = nothing,
        iteration_num::Union{Int64,Nothing} = nothing,
    )

Perform OLS estimation for a specific order (i.e., a particular combination of independent
variables) and store the results in a pre-allocated SharedArray. This implementation
supports out-of-sample testing, t-tests, and residual tests.

# Parameters
- `order::Int64`: The order of the model (i.e., the specific combination of independent
   variables to be considered).
- `depvar::Symbol`: The dependent variable in the regression model.
- `expvars::Vector{Symbol}`: The explanatory variables in the regression model.
- `fixedvariables::Union{Vector{Symbol},Nothing}`: The fixed variables in the regression
   model.
- `datanames_index::Dict{Symbol, Int64}`: The index for data names.
- `depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}}`: The data for the
   dependent variable.
- `expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}}`: The data for the
   explanatory variables.
- `fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing}`: The data
   for the fixed variables, or `nothing` if no fixed variables are present.
- `result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}}`: A pre-allocated
   SharedArray to store the results of the OLS estimation.
- `intercept::Bool`: Whether the regression model should include an intercept term.
- `time::Union{Symbol,Nothing}`: The time variable in the regression model.
- `datatype::DataType`: Specifies the type of the result data (e.g., Float32 or Float64).
- `method`: A symbol indicating the desired estimation method. Can be either `:fast` for a
   faster but less precise estimation, or `:precise` for a slower but more accurate
   estimation (default).
- `outsample::Union{Int64,Vector{Int},Nothing}`: The number of observations or indices of
   observations to be used for out-of-sample validation. Set to `nothing` if no
   out-of-sample validation is desired.
- `criteria`: A vector of symbols representing the information criteria to be calculated
   (e.g., AIC, BIC, etc.).
- `ttest::Bool`: If `true`, perform t-tests for the coefficient estimates.
- `residualtest::Bool`: If `true`, perform residual tests on the selected models.

# Optional Keyword Arguments
- `num_job::Union{Int64,Nothing}`: The unique identifier for the current job.
- `num_jobs::Union{Int64,Nothing}`: The total number of jobs to be executed.
- `iteration_num::Union{Int64,Nothing}`: The iteration number.

# Returns
This function does not return any value. It modifies the `result_data` SharedArray in-place.

# Example
```julia
ols_execute_row!(
    order,
    depvar,
    expvars,
    fixedvariables,
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
    method,
    outsample,
    criteria,
    ttest,
    residualtest
)
```
"""
function ols_execute_row!(
    order::Int64,
    depvar::Symbol,
    expvars::Vector{Symbol},
    fixedvariables::Union{Vector{Symbol},Nothing},
    panel::Union{Symbol,Nothing},
    time::Union{Symbol,Nothing},
    datanames_index::Dict{Symbol,Int64},
    depvar_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    expvars_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    fixedvariables_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    panel_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    time_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16},Nothing},
    result_data::Union{SharedArray{Float64},SharedArray{Float32},SharedArray{Float16}},
    panel_values::Union{Vector{Float64},Vector{Float32},Vector{Float16},Nothing},
    intercept::Bool,
    datatype::DataType,
    method::Symbol,
    outsample::Union{Int64,Vector{Int64},Nothing},
    criteria::Vector{Symbol},
    ttest::Bool,
    residualtest::Bool;
    num_jobs::Union{Int64,Nothing} = nothing,
    num_job::Union{Int64,Nothing} = nothing,
    iteration_num::Union{Int64,Nothing} = nothing,
)
    selected_variables_index = ModelSelection.get_selected_variables(order, expvars, intercept)
    depvar_subset, expvars_subset, fixedvariables_subset = get_insample_subset(
        depvar_data,
        expvars_data,
        fixedvariables_data,
        outsample,
        selected_variables_index,
    )
    outsample_enabled = size(depvar_subset, 1) < size(depvar_data, 1)
    fullexpvars_subset = expvars_subset
    if fixedvariables_subset !== nothing
        fullexpvars_subset = hcat(fullexpvars_subset, fixedvariables_subset)
    end

    nobs = size(depvar_subset, 1)
    ncoef = size(fullexpvars_subset, 2)

    if method in [QR_64, QR_32, QR_16] 
		fact = qr(fullexpvars_subset)
		denominator = depvar_subset
	elseif method in [CHO_64, CHO_32, CHO_16] 
		fact = cholesky(fullexpvars_subset'fullexpvars_subset)
		denominator = fullexpvars_subset'depvar_subset
	elseif method in [SVD_64, SVD_32, SVD_16] 
		fact = svd(fullexpvars_subset)
		denominator = depvar_subset
	else
		error(INVALID_METHOD_BASIC)
	end

    b = fact \ denominator                 # estimate
    ŷ = fullexpvars_subset * b            # predicted values
    er = depvar_subset - ŷ                # in-sample residuals
    er2 = er .^ 2                         # squared errors
    sse = sum(er2)                        # residual sum of squares
    df_e = nobs - ncoef                   # degrees of freedom
    rmse = sqrt(sse / nobs)               # root mean squared error
    r2 = 1 - var(er) / var(depvar_subset) # model R-squared
    r2adj = 1-(1-r2)*((nobs-1)/df_e)      # adjusted R-squared
    F= (r2/(ncoef-1))/((1-r2)/df_e)        # F-statistic

    if ttest
        if method in [QR_64, QR_32, QR_16] 
			diagvcov = sum((UpperTriangular(fact.R) \ Matrix(1.0LinearAlgebra.I, ncoef, ncoef)) .^ 2, dims = 2) * (sse / df_e)
		elseif method in [CHO_64, CHO_32, CHO_16]
			diagvcov = sum((UpperTriangular(fact.U) \ Matrix(1.0LinearAlgebra.I, ncoef, ncoef)) .^ 2, dims = 2) * (sse / df_e)
		elseif method in [SVD_64, SVD_32, SVD_16]
			diagvcov = diag(fact.V * diagm(fact.S)^(-2) * fact.Vt * (sse / df_e))
		else
			error(INVALID_METHOD_BASIC)
		end
		bstd = sqrt.(diagvcov) # std deviation of coefficients
	end

    if outsample_enabled > 0
        depvar_outsample_subset, expvars_outsample_subset, fixedvariables_outsample_subset =
            get_outsample_subset(
                depvar_data,
                expvars_data,
                fixedvariables_data,
                outsample,
                selected_variables_index,
            )
        fullexpvars_outsample_subset = expvars_outsample_subset
        if fixedvariables_outsample_subset !== nothing
            fullexpvars_outsample_subset = hcat(fullexpvars_outsample_subset, fixedvariables_outsample_subset)
        end

        # out-of-sample residuals
        erout = depvar_outsample_subset - fullexpvars_outsample_subset * b

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
        variable_b = datanames_index[Symbol(string(expvars[selected_variable_index], "_b"))]
        result_data[order, variable_b] = datatype(b[index])
        if ttest
            variable_bstd = datanames_index[Symbol(string(expvars[selected_variable_index], "_bstd"))]
            variable_t = datanames_index[Symbol(string(expvars[selected_variable_index], "_t"))]
            result_data[order, variable_bstd] = datatype(bstd[index])
            result_data[order, variable_t] = result_data[order, variable_b] / result_data[order, variable_bstd]
        end
    end

    if fixedvariables !== nothing
        selected_variables_length = length(selected_variables_index)
        for (index, fixedvariable) in enumerate(fixedvariables)
            actual_index = selected_variables_length + index
            variable_b = datanames_index[Symbol(string(fixedvariable, "_b"))]
            result_data[order, variable_b] = datatype(b[actual_index])
            if ttest
                variable_bstd = datanames_index[Symbol(string(fixedvariable, "_bstd"))]
                variable_t = datanames_index[Symbol(string(fixedvariable, "_t"))]
                result_data[order, variable_bstd] = datatype(bstd[actual_index])
                result_data[order, variable_t] = result_data[order, variable_b] / result_data[order, variable_bstd]
            end
        end
    end

    result_data[order, datanames_index[:nobs]] = Int64(trunc(nobs))
    result_data[order, datanames_index[:ncoef]] = ncoef
    result_data[order, datanames_index[:sse]] = datatype(sse)
    result_data[order, datanames_index[:r2]] = datatype(r2)
    result_data[order, datanames_index[:rmse]] = datatype(rmse)
    result_data[order, datanames_index[:order]] = 0
    result_data[order, datanames_index[:r2adj]] = datatype(r2adj)
    result_data[order, datanames_index[:F]] = datatype(F)

    if :aic in criteria || :aicc in criteria
        aic = 2 * result_data[order, datanames_index[:ncoef]] +
            result_data[order, datanames_index[:nobs]] * log(
                result_data[order, datanames_index[:sse]] /
                result_data[order, datanames_index[:nobs]],
            )
    end

    if :aic in criteria
        result_data[order, datanames_index[:aic]] = aic
    end

    if :aicc in criteria
        result_data[order, datanames_index[:aicc]] =
            aic +
            (
                2(result_data[order, datanames_index[:ncoef]] + 1) *
                (result_data[order, datanames_index[:ncoef]] + 2)
            ) / (
                result_data[order, datanames_index[:nobs]] -
                (result_data[order, datanames_index[:ncoef]] + 1) - 1
            )
    end

    if :bic in criteria
        result_data[order, datanames_index[:bic]] =
            result_data[order, datanames_index[:nobs]] *
            log.(result_data[order, datanames_index[:rmse]]) +
            (result_data[order, datanames_index[:ncoef]] - 1) *
            log.(result_data[order, datanames_index[:nobs]]) +
            result_data[order, datanames_index[:nobs]] +
            result_data[order, datanames_index[:nobs]] * log(2π)
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

        regmatw = hcat((ŷ .^ 2), ŷ, ones(size(ŷ, 1)))
        if method in [QR_64, QR_32, QR_16] 
			factw = qr(regmatw)
			denominatorw = er2
		elseif method in [CHO_64, CHO_32, CHO_16] 
			factw = cholesky(regmatw'regmatw)
			denominatorw = regmatw'er2
		elseif method in [SVD_64, SVD_32, SVD_16] # FIXME: Refactor to a const
			factw = svd(regmatw)
			denominatorw = er2
		else
			error(INVALID_METHOD_BASIC)
		end

        regcoeffw = factw \ denominatorw
        residw = er2 - regmatw * regcoeffw
        rsqw = 1 - dot(residw, residw) / dot(er2, er2) # uncentered R^2
        statisticw = n * rsqw
        wtest = ccdf(Chisq(2), statisticw)

        result_data[order, datanames_index[:wtest]] = wtest
        result_data[order, datanames_index[:jbtest]] = jbtest
        if time !== nothing
            e = er
            lag = 1
            xmat = fullexpvars_subset # debe incluir fixedvariables

            n = size(e, 1)
            elag = zeros(datatype, n, lag) # FIXME: Datatype
            for ii = 1:lag
                elag[ii+1:end, ii] = e[1:end-ii]
            end

            offset = lag
            regmatbg = [xmat[offset+1:end, :] elag[offset+1:end, :]]
            if method in [QR_64, QR_32, QR_16] 
				factbg = qr(regmatbg)
				denominatorbg = e[offset+1:end]
			elseif method in [CHO_64, CHO_32, CHO_16] 
				factbg = cholesky(regmatbg'regmatbg)
				denominatorbg = regmatbg'e[offset+1:end]
			elseif method in [SVD_64, SVD_32, SVD_16]
				factbg = svd(regmatbg)
				denominatorbg = e[offset+1:end]
			else
				error(METHOD_INVALID)
			end

            regcoeffbg = factbg \ denominatorbg
            residbg = e[offset+1:end] .- regmatbg * regcoeffbg

            # uncentered R^2
            rsqbg = 1 - dot(residbg, residbg) / dot(e[offset+1:end], e[offset+1:end])
            statisticbg = (n - offset) * rsqbg
            bgtest = ccdf(Chisq(lag), statisticbg)
            result_data[order, datanames_index[:bgtest]] = bgtest
        end
    end
end
