function gsr(
    estimator::Symbol,
    equation::Union{String,Array{String},Array{Symbol}},
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    };
    datanames::Union{Array,Array{Symbol,1},Nothing} = nothing,
    method::Union{Symbol,String} = Preprocessing.METHOD_DEFAULT,
    intercept::Bool = Preprocessing.INTERCEPT_DEFAULT,
    panel::Union{Symbol,String,Nothing} = Preprocessing.PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = Preprocessing.TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = Preprocessing.SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = Preprocessing.REMOVEOUTLIERS_DEFAULT,
    fe_sqr::Union{String,Symbol,Array{String},Array{Symbol},Nothing} = nothing,
    fe_log::Union{String,Symbol,Array{String},Array{Symbol},Nothing} = nothing,
    fe_inv::Union{String,Symbol,Array{String},Array{Symbol},Nothing} = nothing,
    fe_lag::Union{Array{Pair{Symbol,Int64}},Array{Pair{String,Int64}},Nothing} = nothing,
    interaction::Union{Nothing,Array} = nothing,
    preliminaryselection::Union{Nothing,Symbol} = nothing,
    fixedvariables::Union{Nothing,Array} = AllSubsetRegression.FIXEDVARIABLES_DEFAULT,
    outsample::Union{Nothing,Int,Array} = AllSubsetRegression.OUTSAMPLE_DEFAULT,
    criteria::Vector{Symbol} = AllSubsetRegression.CRITERIA_DEFAULT,
    ttest::Bool = AllSubsetRegression.TTEST_DEFAULT,
    ztest::Bool = AllSubsetRegression.ZTEST_DEFAULT,
    modelavg::Bool = AllSubsetRegression.MODELAVG_DEFAULT,
    residualtest::Bool = AllSubsetRegression.RESIDUALTEST_DEFAULT,
    orderresults::Bool = AllSubsetRegression.ORDERRESULTS_DEFAULT,
    kfoldcrossvalidation::Bool = CrossValidation.KFOLDCROSSVALIDATION_DEFAULT,
    numfolds::Int = CrossValidation.NUMFOLDS_DEFAULT,
    testsetshare::Union{Float32,Float64} = CrossValidation.TESTSETSHARE_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
    gsr(
        estimator,
        equation,
        data = data,
        datanames = datanames,
        method = method,
        intercept = intercept,
        panel = panel,
        time = time,
        seasonaladjustment = seasonaladjustment,
        removeoutliers = removeoutliers,
        fe_sqr = fe_sqr,
        fe_log = fe_log,
        fe_inv = fe_inv,
        fe_lag = fe_lag,
        interaction = interaction,
        preliminaryselection = preliminaryselection,
        fixedvariables = fixedvariables,
        outsample = outsample,
        criteria = criteria,
        ttest = ttest,
        ztest = ztest,
        modelavg = modelavg,
        residualtest = residualtest,
        orderresults = orderresults,
        kfoldcrossvalidation = kfoldcrossvalidation,
        numfolds = numfolds,
        testsetshare = testsetshare,
        notify = notify,
    )
end

function gsr(
    estimator::Symbol,
    equation::Union{String,Array{String},Array{Symbol}};
    data::Union{
        Array{Float64},
        Array{Float32},
        Array{Union{Float32,Missing}},
        Array{Union{Float64,Missing}},
        Tuple,
        DataFrame,
        Nothing,
    },
    datanames::Union{Array,Array{Symbol,1},Nothing} = nothing,
    method::Union{Symbol,String} = Preprocessing.METHOD_DEFAULT,
    intercept::Bool = Preprocessing.INTERCEPT_DEFAULT,
    panel::Union{Symbol,String,Nothing} = Preprocessing.PANEL_DEFAULT,
    time::Union{Symbol,String,Nothing} = Preprocessing.TIME_DEFAULT,
    seasonaladjustment::Union{Dict,Array,Nothing} = Preprocessing.SEASONALADJUSTMENT_DEFAULT,
    removeoutliers::Bool = Preprocessing.REMOVEOUTLIERS_DEFAULT,
    fe_sqr::Union{String,Symbol,Array{String},Array{Symbol},Nothing} = nothing,
    fe_log::Union{String,Symbol,Array{String},Array{Symbol},Nothing} = nothing,
    fe_inv::Union{String,Symbol,Array{String},Array{Symbol},Nothing} = nothing,
    fe_lag::Union{Array{Pair{Symbol,Int64}},Array{Pair{String,Int64}},Nothing} = nothing,
    interaction::Union{Nothing,Array} = nothing,
    preliminaryselection::Union{Nothing,Symbol} = nothing,
    fixedvariables::Union{Nothing,Array} = AllSubsetRegression.FIXEDVARIABLES_DEFAULT,
    outsample::Union{Nothing,Int,Array} = AllSubsetRegression.OUTSAMPLE_DEFAULT,
    criteria::Vector{Symbol} = AllSubsetRegression.CRITERIA_DEFAULT,
    ttest::Bool = AllSubsetRegression.TTEST_DEFAULT,
    ztest::Bool = AllSubsetRegression.ZTEST_DEFAULT,
    modelavg::Bool = AllSubsetRegression.MODELAVG_DEFAULT,
    residualtest::Bool = AllSubsetRegression.RESIDUALTEST_DEFAULT,
    orderresults::Bool = AllSubsetRegression.ORDERRESULTS_DEFAULT,
    kfoldcrossvalidation::Bool = CrossValidation.KFOLDCROSSVALIDATION_DEFAULT,
    numfolds::Int = CrossValidation.NUMFOLDS_DEFAULT,
    testsetshare::Union{Float32,Float64} = CrossValidation.TESTSETSHARE_DEFAULT,
    notify = NOTIFY_DEFAULT,
)
    removemissings = fe_lag === nothing

    # TODO: Move notification to every module
    notification(notify, "Processing parameters")
    data = Preprocessing.input(
        equation,
        data = data,
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
    data.options[:testsetshare] = testsetshare

    if featureextraction_enabled(fe_sqr, fe_log, fe_inv, fe_lag, interaction)
        # TODO: Move notification to every module
        notification(notify, "Performing feature extraction")
        data = FeatureExtraction.featureextraction!(
            data,
            fe_sqr = fe_sqr,
            fe_lag = fe_lag,
            fe_log = fe_log,
            fe_inv = fe_inv,
            interaction = interaction,
            removemissings = true,
        )
    end

    original_data = copy_modelselectiondata(data)

    if preliminaryselection_enabled(preliminaryselection)
        # TODO: Move notification to every module
        notification(notify, "Performing preliminary selection")
        data = PreliminarySelection.preliminary_selection!(preliminaryselection, data)
        original_data.extras = data.extras
    end

    AllSubsetRegression.all_subset_regression(
        estimator,
        data,
        outsample = outsample,
        criteria = criteria,
        ttest = ttest,
        ztest = ztest,
        modelavg = modelavg,
        residualtest = residualtest,
        orderresults = orderresults,
    )

    original_data.extras = data.extras

    if crossvalidation_enabled(kfoldcrossvalidation)
        # TODO: Move notification to every module
        notification(notify, "Performing cross validation")
        CrossValidation.kfoldcrossvalidation!(data, original_data, numfolds, testsetshare)
    end

    data.original_data = original_data

    return data
end
