# TODO: Merge _lasso and lasso
function _lasso(data::ModelSelection.ModelSelectionData)
    return _lasso!(data)
end

# TODO: Merge _lasso! and lasso!
function _lasso!(data::ModelSelection.ModelSelectionData)
    res = lasso!(data)
    res[1].extras[:lasso] = Dict()
    res[1].extras[:lasso][:betas] = res[2]

    return res[1]
end

function lasso(data::ModelSelection.ModelSelectionData)
    lasso!(ModelSelection.copy_modelselectiondata(data))
end

function lasso!(data::ModelSelection.ModelSelectionData; addextrasflag = true)
    betas, lambda = lassoselection(data)

    if isnothing(betas)
        return data, map(b -> true, data.expvars)
    end

    data.extras[:lasso_betas] = betas

    vars = map(b -> b != 0, betas)
    lassonumvars = size(filter(b -> b != 0, betas), 1)

    vars = vars[1:size(data.expvars, 1)]

    if data.intercept
        vars[ModelSelection.get_column_index(CONS, data.expvars)] = true
    end

    data.expvars = data.expvars[vars]
    data.expvars_data = data.expvars_data[:, vars]

    if (addextrasflag)
        data = addextras(data, lassonumvars, betas, lambda, vars)
    end

    return data, vars
end

function computablevars(nvars::Int)
    return 20
    min(Int(floor(log(2, Sys.total_memory() / 2^30) + 21)), nvars)
end

function lassoselection(data)
    data = ModelSelection.filter_data_by_empty_values!(data)
    data = ModelSelection.convert_data!(data)
    nvars = computablevars(size(data.expvars, 1))

    if nvars >= size(data.expvars, 1)
        return nothing, nothing
    end

    penalty_factor = vcat(ones(size(data.expvars, 1)), zeros(size(data.fixedvariables, 1)))
    expvars_data = hcat(data.expvars_data, data.fixedvariables_data)
    path = glmnet(
        expvars_data,
        data.depvar_data;
        nlambda = 1000,
        penalty_factor = penalty_factor,
    )

    best = 1
    for (i, cant) in enumerate(nactive(path.betas))
        if cant >= nvars
            if cant == nvars
                best = i
            end
            break
        end
        best = i
    end

    return path.betas[:, best], path.lambda[best]
end
