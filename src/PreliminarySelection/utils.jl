function validate_estimator(estimator::Symbol)
    if estimator !== :ols
        throw(ArgumentError(ESTIMATOR_NOT_SUPPORTED))
    end
end

"""
Add values to extras
"""
function addextras!(data, lassonumvars, betas, lambda, vars)
    extras = Dict(
        :preliminaryselection => :lasso,
        :numvars => lassonumvars,
        :betas => betas,
        :lambda => lambda,
        :nobs => data.nobs,
        :vars => vars,
    )
    data.extras[PRELIMINARYSELECTION_EXTRAKEY] = extras
    return data
end
