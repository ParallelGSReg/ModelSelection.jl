"""
Add values to extras
"""
function addextras(data, lassonumvars, betas, lambda, vars)
    data.extras[ModelSelection.generate_extra_key(
        PRELIMINARYSELECTION_EXTRAKEY,
        data.extras,
    )] = Dict(
        :preliminaryselection => :lasso,
        :lassonumvars => lassonumvars,
        :lassobetas => betas,
        :lassolambda => lambda,
        :nobs => data.nobs,
        :vars => vars,
    )
    return data
end
