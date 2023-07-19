function gsr(
    estimator::Symbol,
    equation::Union{String,Array{String},Array{Symbol}},
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
    datanames::Union{Array{Symbol},Nothing} = nothing,
    method::Union{Symbol,Nothing} = nothing,
    intercept::Bool = Preprocessing.INTERCEPT_DEFAULT,
    panel::Union{Symbol,Nothing} = Preprocessing.PANEL_DEFAULT,
    time::Union{Symbol,Nothing} = Preprocessing.TIME_DEFAULT,
    seasonaladjustment::Union{Dict{Symbol,Int64},Nothing} = Preprocessing.SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = Preprocessing.REMOVEOUTLIERS_DEFAULT,
    fe_sqr::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_log::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_inv::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    fe_lag::Union{Dict{Symbol,Int64},Nothing} = nothing,
    interaction::Union{Vector{Tuple{Symbol,Symbol}},Nothing} = nothing,
    preliminaryselection::Union{Symbol,Nothing} = nothing,
    fixedvariables::Union{Symbol,Vector{Symbol},Nothing} = AllSubsetRegression.FIXEDVARIABLES_DEFAULT,
    outsample::Union{Int64,Array{Int64},Nothing} = AllSubsetRegression.OUTSAMPLE_DEFAULT, # NOTE: Array posición de la observación
    criteria::Union{Symbol,Vector{Symbol},Nothing} = nothing,
    ttest::Bool = AllSubsetRegression.TTEST_DEFAULT,
    ztest::Bool = AllSubsetRegression.ZTEST_DEFAULT,
    modelavg::Bool = AllSubsetRegression.MODELAVG_DEFAULT,
    residualtest::Bool = AllSubsetRegression.RESIDUALTEST_DEFAULT,
    orderresults::Bool = AllSubsetRegression.ORDERRESULTS_DEFAULT,
    kfoldcrossvalidation::Bool = CrossValidation.KFOLDCROSSVALIDATION_DEFAULT,
    numfolds::Int64 = CrossValidation.NUMFOLDS_DEFAULT,
    notify = nothing,
)
    AllSubsetRegression.validate_estimator(estimator)
    datatype = AllSubsetRegression.get_datatype(estimator, method)

    removemissings = fe_lag === nothing
    data = Preprocessing.input(
        equation,
        data,
        datanames = datanames,
        datatype = datatype,
        intercept = intercept,
        fixedvariables = fixedvariables,
        panel = panel,
        time = time,
        seasonaladjustment = seasonaladjustment,
        removeoutliers = removeoutliers,
        removemissings = removemissings,
        notify = notify,
    )

    if fe_sqr !== nothing || fe_log !== nothing || fe_inv !== nothing || fe_lag !== nothing || interaction !== nothing
        data = FeatureExtraction.featureextraction!(
            data,
            fe_sqr = fe_sqr,
            fe_lag = fe_lag,
            fe_log = fe_log,
            fe_inv = fe_inv,
            interaction = interaction,
            removemissings = true,
            notify = notify,
        )
    end

    original_data = copy_modelselectiondata(data)

    if preliminaryselection_enabled(preliminaryselection)
        PreliminarySelection.validate_estimator(estimator)
        data = PreliminarySelection.preliminary_selection!(preliminaryselection, data, notify = notify)
        original_data.extras = data.extras
    end

    AllSubsetRegression.all_subset_regression!(
        estimator,
        data,
        outsample = outsample,
        criteria = criteria,
        ttest = ttest,
        ztest = ztest,
        modelavg = modelavg,
        residualtest = residualtest,
        orderresults = orderresults,
        notify = notify ,
    )

    original_data.extras = data.extras

    if crossvalidation_enabled(kfoldcrossvalidation)
        CrossValidation.kfoldcrossvalidation!(data, original_data, numfolds, notify = notify)
    end

    data.original_data = original_data

    data.options[:estimator] = estimator
    data.options[:equation] = equation
    data.options[:datanames] = datanames
    data.options[:method] = method
    data.options[:intercept] = intercept
    data.options[:panel] = panel
    data.options[:time] = time
    data.options[:seasonaladjustment] = seasonaladjustment
    data.options[:removeoutliers] = removeoutliers
    data.options[:fe_sqr] = fe_sqr
    data.options[:fe_log] = fe_log
    data.options[:fe_inv] = fe_inv
    data.options[:fe_lag] = fe_lag
    data.options[:interaction] = interaction
    data.options[:preliminaryselection] = preliminaryselection
    data.options[:fixedvariables] = fixedvariables
    data.options[:outsample] = outsample
    data.options[:criteria] = criteria
    data.options[:ttest] = ttest
    data.options[:ztest] = ztest
    data.options[:modelavg] = modelavg
    data.options[:residualtest] = residualtest
    data.options[:orderresults] = orderresults
    data.options[:kfoldcrossvalidation] = kfoldcrossvalidation
    data.options[:numfolds] = numfolds

    return data
end
