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
    data.extras[ModelSelection.generate_extra_key(
        PRELIMINARYSELECTION_EXTRAKEY,
        data.extras,
    )] = extras
    return data
end
