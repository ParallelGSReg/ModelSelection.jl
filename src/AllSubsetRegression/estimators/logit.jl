"""
    logit(
        data::ModelSelectionData;
        outsample::Union{Nothing,Int,Array} = OUTSAMPLE_DEFAULT,
        criteria::Vector{Symbol} = CRITERIA_DEFAULT,
        ztest::Bool = TTEST_DEFAULT,
        modelavg::Bool = MODELAVG_DEFAULT,
        residualtest::Bool = RESIDUALTEST_DEFAULT,
        orderresults::Bool = ORDERRESULTS_DEFAULT,
    ) -> ModelSelectionData

Perform logistic regression model selection on the on the provided `ModelSelectionData` using the specified options and returns a new ModelSelectionData object containing the results.

# Arguments
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used in the model selection process.

# Keyword Arguments
- `outsample::Union{Nothing,Int,Array}`: The number of out-of-sample observations, an array of out-of-sample indices, or nothing. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: A vector of symbols representing the selection criteria to be used. Default: `CRITERIA_DEFAULT`.
- `ztest::Bool`: If `true`, perform z-tests for the coefficient estimates. Default: `ZTEST_DEFAULT`.
- `modelavg::Bool`: If `true`, perform model averaging. Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform residual tests. Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results by the specified criteria. Default: `ORDERRESULTS_DEFAULT`.

# Returns
- `ModelSelectionData`: The copy of the input `ModelSelectionData` object containing the logit regression results.

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
)
    return logit!(
        ModelSelection.copy_modelselectiondata(data),
        outsample = outsample,
        criteria = criteria,
        ztest = ztest,
        modelavg = modelavg,
        residualtest = residualtest,
        orderresults = orderresults,
    )
end

"""
    logit!(
        data::ModelSelectionData;
        outsample::Union{Nothing,Int,Array} = OUTSAMPLE_DEFAULT,
        criteria::Vector{Symbol} = CRITERIA_DEFAULT,
        ztest::Bool = TTEST_DEFAULT,
        modelavg::Bool = MODELAVG_DEFAULT,
        residualtest::Bool = RESIDUALTEST_DEFAULT,
        orderresults::Bool = ORDERRESULTS_DEFAULT,
    ) -> ModelSelectionData

Perform logistic regression model selection on the on the provided `ModelSelectionData` using the specified options. This function mutates the input `ModelSelectionData` object.

# Arguments
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used in the model selection process.

# Keyword Arguments
- `outsample::Union{Nothing,Int,Array}`: The number of out-of-sample observations, an array of out-of-sample indices, or nothing. Default: `OUTSAMPLE_DEFAULT`.
- `criteria::Vector{Symbol}`: A vector of symbols representing the selection criteria to be used. Default: `CRITERIA_DEFAULT`.
- `ztest::Bool`: If `true`, perform z-tests for the coefficient estimates. Default: `ZTEST_DEFAULT`.
- `modelavg::Bool`: If `true`, perform model averaging. Default: `MODELAVG_DEFAULT`.
- `residualtest::Bool`: If `true`, perform residual tests. Default: `RESIDUALTEST_DEFAULT`.
- `orderresults::Bool`: If `true`, order the results by the specified criteria. Default: `ORDERRESULTS_DEFAULT`.

# Returns
- `ModelSelectionData`: The copy of the input `ModelSelectionData` object containing the logit regression results.

# Example
```julia
result = logit!(model_selection_data)
"""
function logit!(
    data::ModelSelectionData;
    outsample::Union{Nothing,Int,Array} = OUTSAMPLE_DEFAULT,
    criteria::Vector{Symbol} = CRITERIA_DEFAULT,
    ztest::Bool = ZTEST_DEFAULT,
    modelavg::Bool = MODELAVG_DEFAULT,
    residualtest::Bool = RESIDUALTEST_DEFAULT,
    orderresults::Bool = ORDERRESULTS_DEFAULT,
)
    validate_criteria(criteria, AVAILABLE_LOGIT_CRITERIA)
    ttest = ztest  # FIXME
    result = create_result(
        data,
        outsample,
        criteria,
        ttest,
        modelavg,
        residualtest,
        orderresults,
    )
    logit_execute!(data, result)
    ModelSelection.addresult!(data, result)
    data = addextras!(data, result)
    return data
end

"""
logit_execute!(
        data::ModelSelectionData,
        result::AllSubsetRegressionResult
    ) -> AllSubsetRegressionResult

Perform logistic regression model selection analysis for all possible subsets of the explanatory variables in the given `ModelSelectionData`. This function mutates the input `AllSubsetRegressionResult` object.

# Arguments
- `data::ModelSelectionData`: The input `ModelSelectionData` object containing the data used in the model selection process.
- `result::AllSubsetRegressionResult`: The `AllSubsetRegressionResult` object to store the results of the logit regression analysis.

# Returns
- `AllSubsetRegressionResult`: The updated input `AllSubsetRegressionResult` object containing the logit regression results for all possible subsets of the explanatory variables.

# Example
```julia
logit_execute!(model_selection_data, all_subset_regression_result)
```
"""
function logit_execute!(data::ModelSelectionData, result::AllSubsetRegressionResult)
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
    result_data =
        fill!(SharedArray{data.datatype}(num_operations, size(result.datanames, 1)), NaN)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)

    ncoef_gum = size(expvars_data, 2)
    depvar_without_outsample_subset,
    expvars_without_outsample_subset,
    fixedvariables_without_outsample_subset = get_insample_subset(
        depvar_data,
        expvars_data,
        fixedvariables_data,
        result.outsample,
        collect(1:ncoef_gum),
    )
    fullexpvars_without_outsample_subset = expvars_without_outsample_subset
    if fixedvariables_without_outsample_subset !== nothing
        fullexpvars_without_outsample_subset =
            hcat(expvars_without_outsample_subset, fixedvariables_without_outsample_subset)
    end

    gum_model = GLM.fit(
        GeneralizedLinearModel,
        fullexpvars_without_outsample_subset,
        depvar_without_outsample_subset,
        Binomial(),
        LogitLink(),
        start = zeros(size(fullexpvars_without_outsample_subset, 2)),
    )
    start_coef = coeftable(gum_model).cols[1]

    if nprocs() == nworkers()
        for order = 1:num_operations
            # TODO: Split in multiple lines
            logit_execute_row!(
                order,
                data.depvar,
                data.expvars,
                data.fixedvariables,
                start_coef,
                datanames_index,
                depvar_data,
                expvars_data,
                fixedvariables_data,
                result_data,
                data.intercept,
                data.time,
                data.datatype,
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
                @spawnat num_job + 1 logit_execute_job!(
                    num_job,
                    num_jobs,
                    ops_per_worker,
                    data.depvar,
                    data.expvars,
                    data.fixedvariables,
                    start_coef,
                    datanames_index,
                    depvar_data,
                    expvars_data,
                    fixedvariables_data,
                    result_data,
                    data.intercept,
                    data.time,
                    data.datatype,
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
                logit_execute_row!(
                    order,
                    data.depvar,
                    data.expvars,
                    data.fixedvariables,
                    start_coef,
                    datanames_index,
                    depvar_data,
                    expvars_data,
                    fixedvariables_data,
                    result_data,
                    data.intercept,
                    data.time,
                    data.datatype,
                    result.outsample,
                    result.criteria,
                    result.ttest,
                    result.residualtest,
                )
            end
        end
    end

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

    # FIXME
    # if result.modelavg
    # 	delta = maximum(result.data[:, datanames_index[:order]]) .- result.data[:, datanames_index[:order]]
    # 	w1 = exp.(-delta / 2)
    # 	result.data[:, datanames_index[:weight]] = w1 ./ sum(w1)
    # 	result.modelavg_data = Vector{Float64}(undef, size(result.datanames))
    # 	weight_pos = (result.ttest) ? 4 : 2
    # 	for expvar in data.expvars
    # 		obs = result.data[:, datanames_index[Symbol(string(expvar, "_b"))]]
    # 		if result.ttest
    # 			obs = hcat(obs, result.data[:, datanames_index[Symbol(string(expvar, "_bstd"))]])
    # 			obs = hcat(obs, result.data[:, datanames_index[Symbol(string(expvar, "_t"))]])
    # 		end
    # 		obs = hcat(obs, result.data[:, datanames_index[:weight]])
    # 
    # 		obs = obs[findall(x -> !isnan(obs[x, 1]), 1:size(obs, 1)), :]
    # 		obs[:, weight_pos] /= sum(obs[:, weight_pos])
    # 
    # 		result.modelavg_data[datanames_index[Symbol(string(expvar, "_b"))]] = sum(obs[:, 1] .* obs[:, weight_pos])
    # 		if result.ttest
    # 			result.modelavg_data[datanames_index[Symbol(string(expvar, "_bstd"))]] = sum(obs[:, 2] .* obs[:, weight_pos])
    # 			result.modelavg_data[datanames_index[Symbol(string(expvar, "_t"))]] = sum(obs[:, 3] .* obs[:, weight_pos])
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

    return result
end

"""
# TODO: typing and example
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
        ttest,
        residualtest,
    )

Execute a single job in the logistic regression (logit) procedure. This function is called by the main `logit!` function to parallelize the model estimation across multiple workers.

# Arguments
- `num_job`: The job number.
- `num_jobs`: The total number of jobs.
- `ops_per_worker`: The number of operations per worker.
- `depvar`: The dependent variable.
- `expvars`: The explanatory variables.
- `fixedvariables`: The fixed variables.
- `start_coef`: The starting coefficients.
- `datanames_index`: The index for the names of data.
- `depvar_data`: The dependent variable data.
- `expvars_data`: The explanatory variables data.
- `fixedvariables_data`: The fixed variables data.
- `result_data`: The results data.
- `intercept`: A boolean indicating if the model should include an intercept.
- `time`: The time variable.
- `datatype`: The type of data.
- `outsample`: The out-of-sample data used for validation.
- `criteria`: The criteria used for model selection.
- `ttest`: A boolean indicating if a t-test should be performed.
- `residualtest`: A boolean indicating if a residual test should be performed.
"""
function logit_execute_job!(
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
    ttest,
    residualtest,
)
    for j = 1:ops_per_worker
        order = (j - 1) * num_jobs + num_job
        logit_execute_row!(
            order,
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
            ttest,
            residualtest,
            num_jobs = num_jobs,
            num_job = num_job,
            iteration_num = j,
        )
    end
end


function logit_execute_row!(
    order,
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
    ttest,
    residualtest;
    num_jobs = nothing,
    num_job = nothing,
    iteration_num = nothing,
)
    selected_variables_index =
        ModelSelection.get_selected_variables(order, expvars, intercept)
    depvar_subset, expvars_subset, fixedvariables_subset = get_insample_subset(
        depvar_data,
        expvars_data,
        fixedvariables_data,
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

    nobs = size(depvar_subset, 1)
    ncoef = size(fullexpvars_subset, 2)

    start_coef_subset = start_coef[selected_variables_index]
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
    ŷ = predict(model)
    er2 = model.rr.devresid      # squared errors
    sse = sum(er2)                        # residual sum of squares
    df_e = nobs - ncoef                   # degrees of freedom	
    rmse = sqrt(sse / nobs)               # root mean squared error

    ll = GLM.loglikelihood(model)

    if ttest
        bstd = stderror(model)
    end

    # FIXME
    # if outsample_enabled > 0
    # 	depvar_outsample_subset, expvars_outsample_subset = get_outsample_subset(depvar_data, expvars_data, outsample, selected_variables_index)
    # 	erout = depvar_outsample_subset - expvars_outsample_subset * b  # out-of-sample residuals
    # 	sseout = sum(erout .^ 2)                                        # residual sum of squares
    # 	outsample_count = outsample
    # 	if (isa(outsample, Array))
    # 		outsample_count = size(outsample, 1)
    # 	end
    # 	rmseout = sqrt(sseout / outsample_count)                        # root mean squared error
    # 	result_data[order, datanames_index[:rmseout]] = rmseout
    # end

    result_data[order, datanames_index[:index]] = order
    for (index, selected_variable_index) in enumerate(selected_variables_index)
        result_data[
            order,
            datanames_index[Symbol(string(expvars[selected_variable_index], "_b"))],
        ] = datatype(b[index])
        if ttest
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

    result_data[order, datanames_index[:nobs]] = nobs
    result_data[order, datanames_index[:ncoef]] = ncoef
    result_data[order, datanames_index[:sse]] = datatype(sse)
    result_data[order, datanames_index[:rmse]] = datatype(rmse)
    result_data[order, datanames_index[:order]] = 0

    # result_data[order, datanames_index[:loglikelihood]] = datatype(loglikelihood)

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

    # FIXME:
    # result_data[order, datanames_index[:F]] =
    #	(result_data[order, datanames_index[:r2]] / (result_data[order, datanames_index[:ncoef]] - 1)) / ((1 - result_data[order, datanames_index[:r2]]) / (result_data[order, datanames_index[:nobs]] - result_data[order, datanames_index[:ncoef]]))

    # FIXME
    # if residualtest
    # 	x = er
    # 	n = length(x)
    # 	m1 = sum(x) / n
    # 	m2 = sum((x .- m1) .^ 2) / n
    # 	m3 = sum((x .- m1) .^ 3) / n
    # 	m4 = sum((x .- m1) .^ 4) / n
    # 	b1 = (m3 / m2^(3 / 2))^2
    # 	b2 = (m4 / m2^2)
    # 	statistic = n * b1 / 6 + n * (b2 - 3)^2 / 24
    # 	d = Chisq(2.0)
    # 	jbtest = 1 .- cdf(d, statistic)
    # 
    # 	regmatw = hcat((ŷ .^ 2), ŷ, ones(size(ŷ, 1)))
    # 	qrfw = qr(regmatw)
    # 	regcoeffw = qrfw \ er2
    # 	residw = er2 - regmatw * regcoeffw
    # 	rsqw = 1 - dot(residw, residw) / dot(er2, er2) # uncentered R^2
    # 	statisticw = n * rsqw
    # 	wtest = ccdf(Chisq(2), statisticw)
    # 
    # 	result_data[order, datanames_index[:wtest]] = wtest
    # 	result_data[order, datanames_index[:jbtest]] = jbtest
    # 	if time !== nothing
    # 		e = er
    # 		lag = 1
    # 		xmat = expvars_subset
    # 
    # 		n = size(e, 1)
    # 		elag = zeros(Float64, n, lag)
    # 		for ii in 1:lag
    # 			elag[ii+1:end, ii] = e[1:end-ii]
    # 		end
    # 
    # 		offset = lag
    # 		regmatbg = [xmat[offset+1:end, :] elag[offset+1:end, :]]
    # 		qrfbg = qr(regmatbg)
    # 		regcoeffbg = qrfbg \ e[offset+1:end]
    # 		residbg = e[offset+1:end] .- regmatbg * regcoeffbg
    # 		rsqbg = 1 - dot(residbg, residbg) / dot(e[offset+1:end], e[offset+1:end]) # uncentered R^2
    # 		statisticbg = (n - offset) * rsqbg
    # 		bgtest = ccdf(Chisq(lag), statisticbg)
    # 		result_data[order, datanames_index[:bgtest]] = bgtest
    # 	end
    # end
end
