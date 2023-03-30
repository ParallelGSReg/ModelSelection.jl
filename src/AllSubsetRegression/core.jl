include("estimators/ols.jl")
include("estimators/logit.jl")

function all_subset_regression(
    estimator::Symbol,
    data::ModelSelection.ModelSelectionData;
    outsample::Union{Nothing,Int,Array} = OUTSAMPLE_DEFAULT,
    criteria::Vector{Symbol} = CRITERIA_DEFAULT,
    ttest::Bool = ZTEST_DEFAULT,
    ztest::Bool = ZTEST_DEFAULT,
    modelavg::Bool = MODELAVG_DEFAULT,
    residualtest::Bool = RESIDUALTEST_DEFAULT,
    orderresults::Bool = ORDERRESULTS_DEFAULT,
)
    if ttest && ztest
        throw(ArgumentError(TTEST_ZTEST_BOTH_TRUE))
    end

    if estimator == :ols
        AllSubsetRegression.ols!(
            data,
            outsample = outsample,
            criteria = criteria,
            ttest = ttest,
            modelavg = modelavg,
            residualtest = residualtest,
            orderresults = orderresults,
        )
    elseif estimator == :logit
        AllSubsetRegression.logit!(
            data,
            fixedvariables = data.fixedvariables,
            outsample = outsample,
            criteria = criteria,
            ztest = ztest,
            modelavg = modelavg,
            residualtest = residualtest,
            orderresults = orderresults,
        )
    else
        throw(ArgumentError(INVALID_ESTIMATOR))
    end
end

"""
to_string
"""
function to_string(
    data::ModelSelection.ModelSelectionData,
    result::AllSubsetRegressionResult,
)
    datanames_index = ModelSelection.create_datanames_index(result.datanames)

    out = ""
    out *= @sprintf("\n")
    out *= @sprintf(
        "══════════════════════════════════════════════════════════════════════════════\n"
    )
    out *= @sprintf(
        "                              Best model results                              \n"
    )
    out *= @sprintf(
        "══════════════════════════════════════════════════════════════════════════════\n"
    )
    out *= @sprintf(
        "                                                                              \n"
    )
    out *= @sprintf(
        "                                     Dependent variable: %s                   \n",
        data.depvar
    )
    out *= @sprintf(
        "                                     ─────────────────────────────────────────\n"
    )
    out *= @sprintf(
        "                                                                              \n"
    )
    out *= @sprintf(" Selected covariates                 Coef.")
    if result.ttest
        out *= @sprintf("        Std.         t-test")
    end
    out *= @sprintf("\n")
    out *= @sprintf(
        "──────────────────────────────────────────────────────────────────────────────\n"
    )

    cols = ModelSelection.get_selected_variables(
        Int64(result.bestresult_data[datanames_index[:index]]),
        data.expvars,
        data.intercept,
    )

    for pos in cols
        varname = data.expvars[pos]
        out *= @sprintf(" %-35s", varname)
        out *= @sprintf(
            " %-10f",
            result.bestresult_data[datanames_index[Symbol(string(varname, "_b"))]]
        )
        if result.ttest
            out *= @sprintf(
                "   %-10f",
                result.bestresult_data[datanames_index[Symbol(string(varname, "_bstd"))]]
            )
            out *= @sprintf(
                "   %-10f",
                result.bestresult_data[datanames_index[Symbol(string(varname, "_t"))]]
            )
        end
        out *= @sprintf("\n")
    end

    out *= @sprintf(
        "──────────────────────────────────────────────────────────────────────────────\n"
    )
    out *= @sprintf(
        " Observations                        %-10d\n",
        result.bestresult_data[datanames_index[:nobs]]
    )
    out *= @sprintf(
        " F-statistic                         %-10f\n",
        result.bestresult_data[datanames_index[:F]]
    )
    if :r2adj in result.datanames
        out *= @sprintf(
            " Adjusted R²                         %-10f\n",
            result.bestresult_data[datanames_index[:r2adj]]
        )
    end
    for criteria in result.criteria
        if AVAILABLE_CRITERIA[criteria]["verbose_show"] && criteria != :r2adj
            out *= @sprintf(
                " %-30s      %-10f\n",
                AVAILABLE_CRITERIA[criteria]["verbose_title"],
                result.bestresult_data[datanames_index[criteria]]
            )
        end
    end

    if !result.modelavg
        out *= @sprintf(
            "──────────────────────────────────────────────────────────────────────────────\n"
        )
    else
        out *= @sprintf("\n")
        out *= @sprintf("\n")
        out *= @sprintf(
            "══════════════════════════════════════════════════════════════════════════════\n"
        )
        out *= @sprintf(
            "                            Model averaging results                           \n"
        )
        out *= @sprintf(
            "══════════════════════════════════════════════════════════════════════════════\n"
        )
        out *= @sprintf(
            "                                                                              \n"
        )
        out *= @sprintf(
            "                                     Dependent variable: %s                   \n",
            data.depvar
        )
        out *= @sprintf(
            "                                     ─────────────────────────────────────────\n"
        )
        out *= @sprintf(
            "                                                                              \n"
        )
        out *= @sprintf(" Covariates                          Coef.")
        if result.ttest
            out *= @sprintf("        Std.         t-test")
        end
        out *= @sprintf("\n")
        out *= @sprintf(
            "──────────────────────────────────────────────────────────────────────────────\n"
        )

        for varname in data.expvars
            out *= @sprintf(" %-35s", varname)
            out *= @sprintf(
                " %-10f",
                result.modelavg_data[datanames_index[Symbol(string(varname, "_b"))]]
            )
            if result.ttest
                out *= @sprintf(
                    "   %-10f",
                    result.modelavg_data[datanames_index[Symbol(string(varname, "_bstd"))]]
                )
                out *= @sprintf(
                    "   %-10f",
                    result.modelavg_data[datanames_index[Symbol(string(varname, "_t"))]]
                )
            end
            out *= @sprintf("\n")
        end
        out *= @sprintf("\n")
        out *= @sprintf(
            "──────────────────────────────────────────────────────────────────────────────\n"
        )
        out *= @sprintf(
            " Observations                        %-10d\n",
            result.modelavg_data[datanames_index[:nobs]]
        )
        out *= @sprintf(
            " Adjusted R²                         %-10f\n",
            result.modelavg_data[datanames_index[:r2adj]]
        )
        out *= @sprintf(
            " F-statistic                         %-10f\n",
            result.modelavg_data[datanames_index[:F]]
        )
        out *= @sprintf(
            " Combined criteria                   %-10f\n",
            result.modelavg_data[datanames_index[:order]]
        )
        out *= @sprintf(
            "──────────────────────────────────────────────────────────────────────────────\n"
        )

    end

    return out
end
