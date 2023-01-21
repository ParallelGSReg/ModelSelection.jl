const TEX_TEMPLATE_FOLDER = joinpath(dirname(@__FILE__), "tpl")
const DEFAULT_LATEX_DEST_FOLDER = "./LaTeX"

"""
Create required figures by the template. Generate png images into the dest folder.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `destfolder::String`: destination directory.
"""
function create_figures(data::ModelSelection.ModelSelectionData, destfolder::String)
	expvars2 = filter(x -> x != :_cons, data.expvars)
	criteria_diff = Array{Any}(undef, size(expvars2, 1), 2)

	for (i, expvar) in enumerate(expvars2)
		bcol = ModelSelection.get_column_index(Symbol("$(expvar)_b"), data.results[1].datanames)
		tcol = ModelSelection.get_column_index(Symbol("$(expvar)_t"), data.results[1].datanames)

		r2col = ModelSelection.get_column_index(:r2adj, data.results[1].datanames)
		x = data.results[1].data[findall(x -> !isnan(x), data.results[1].data[:, bcol]), bcol]
		if tcol !== nothing
			y = data.results[1].data[findall(x -> !isnan(x), data.results[1].data[:, tcol]), tcol]
			biden = kde((x, y), npoints = (100, 100))
			contour(biden.x, biden.y, biden.density; xlabel = "Coef. $expvar", ylabel = "t-test $expvar")
			savefig(joinpath(destfolder, "contour_$(expvar)_b_t.png"))
			wireframe(biden.x, biden.y, biden.density; xlabel = "Coef. $expvar", ylabel = "t-test $expvar", camera = (45, 45))
			savefig(joinpath(destfolder, "wireframe_$(expvar)_b_t.png"))
		end

		criteria_with = data.results[1].data[findall(x -> !isnan(x), data.results[1].data[:, bcol]), r2col]
		criteria_without = data.results[1].data[findall(x -> isnan(x), data.results[1].data[:, bcol]), r2col]

		uniden_with = kde(criteria_with)
		uniden_without = kde(criteria_without)

		p1 = plot(range(min(criteria_with...), stop = max(criteria_with...), length = 150), z -> pdf(uniden_with, z)) # FIXME: This should not be working
		p1 = plot!(range(min(criteria_without...), stop = max(criteria_without...), length = 150), z -> pdf(uniden_without, z)) # FIXME: This should not be working
		plot(p1, label = ["Including $(expvar)" "Excluding $(expvar)"], ylabel = "Adj. R2") # FIXME: This should not be working
		savefig(joinpath(destfolder, "Kdensity_criteria_$(expvar).png"))

		p2 = violin(["Including $(expvar)" "Excluding $(expvar)"], [criteria_with, criteria_without], leg = false, marker = (0.1, stroke(0)), alpha = 0.50, color = :blues)
		p2 = boxplot!(["Including $(expvar)" "Excluding $(expvar)"], [criteria_with, criteria_without], leg = false, marker = (0.3, stroke(2)), alpha = 0.6, color = :orange)
		plot(p2, ylabel = "Adj. R2") # FIXME: This should not be working
		savefig(joinpath(destfolder, "BoxViolinDot_$(expvar).png"))

		criteria_diff[i, 1] = mean(criteria_with) - mean(criteria_without)
		criteria_diff[i, 2] = "$(expvar)"
	end
	a = sortslices(criteria_diff, dims = 1)
	labels = convert(Array{String}, a[:, 2])
	bar(a[:, 1], orientation=:h, yticks=(1:size(a,1),labels), legend = false, color = :blues, xlabel = "Average impact of each variable on the Adj. R2")
	savefig(joinpath(destfolder, "cov_relevance.png"))

	numofpositivegainsvariables = size(findall(x -> x > 0, a[:, 1]), 1)
	numofnegativegainsvariables = size(findall(x -> x < 0, a[:, 1]), 1)
	intelligent_text = Dict(
		"numofpositivegainsvariables" => numofpositivegainsvariables,
		"numofnegativegainsvariables" => numofnegativegainsvariables,
		"multiple_positive_variables" => numofpositivegainsvariables > 1,
		"multiple_negative_variables" => numofnegativegainsvariables > 1,
		"no_negative_variables" => numofnegativegainsvariables == 0,
		"bestvar" => a[1, 2],
		"bestvar_gainsinperc" => a[1, 1],
		"worstvar" => a[end, 2],
		"worstvar_gainsinperc" => a[end, 1],
	)
	return intelligent_text
end

"""
Copy the required files from the tpl folder. The existent content will be replaced. The folder is created if not exists.
# Arguments
- `destfolder::AbstractString`: destination folder.
"""
function create_workspace(destfolder::AbstractString)
	cp(TEX_TEMPLATE_FOLDER, destfolder, force = true)
end

"""
Gets columns statistics.
# Arguments
- `data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}}`: column data.
"""
function get_col_statistics(
	data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
)
	nnan = filter(x -> !isnan(x), data)
	if (isempty(nnan))
		return Dict(
			"avg" => "",
			"median" => "",
			"mode" => "",
			"std" => "",
			"skew" => "",
			"kurt" => "",
		)
	end
	return Dict(
		"avg" => @sprintf("%.3f", mean(nnan)),
		"median" => @sprintf("%.3f", median(nnan)),
		"mode" => @sprintf("%.3f", mode(nnan)),
		"std" => @sprintf("%.3f", std(nnan)),
		"skew" => @sprintf("%.3f", skewness(nnan)),
		"kurt" => @sprintf("%.3f", kurtosis(nnan)),
	)
end

"""
Exports to latex.
# Arguments
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `originaldata::String: the original model selection data.
- `path::{String, Nothing}`: latex path.
"""
function latex(
	data::ModelSelection.ModelSelectionData,
	originaldata::ModelSelection.ModelSelectionData;
	path::Union{String, Nothing} = DEFAULT_LATEX_DEST_FOLDER,
)
	tempfolder = tempname()
	mkdir(tempfolder)
	addextras(data, :latex, nothing, tempfolder)
	if size(data.results, 1) > 0
		dict = Dict()
		latex!(dict, data, originaldata)
		for i in 1:size(data.results, 1)
			latex!(dict, data, originaldata, data.results[i])
		end
		create_workspace(tempfolder)
		if data.results[1].ttest
			dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["intelligent_text"] = create_figures(data, tempfolder)
		end
		render_latex(dict, tempfolder)
		zip_folder(tempfolder, path)
	end
	rm(tempfolder, force = true, recursive = true)
end

"""
Generates latex file.
# Arguments
- `dict::Dict`: TODO add definition.
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `originaldata::String: the original model selection data.
"""
function latex!(
	dict::Dict,
	data::ModelSelection.ModelSelectionData,
	originaldata::ModelSelection.ModelSelectionData,
)
	# Preprocessing
	preprocessing_dict = process_dict(data.extras[Preprocessing.PREPROCESSING_EXTRAKEY])
	preprocessing_dict["equation"] = join(map(x -> "$x", filter(x -> x != :_cons, preprocessing_dict["datanames"])), " ")
	preprocessing_dict["datanames"] = string("[:", join(preprocessing_dict["datanames"], ", :"), "]")
	preprocessing_dict["descriptive"] = []

	datanames_index = ModelSelection.create_datanames_index(originaldata.expvars)

	for (i, var) in enumerate(originaldata.expvars)
		orig = originaldata.expvars_data[:, datanames_index[var]]
		obs = collect(skipmissing(orig))
		c_obs = length(obs)
		c_miss = length(orig) - c_obs
		push!(
			preprocessing_dict["descriptive"],
			Dict(
				"name" => replace(string(var), "_" => "\\_"),
				"nobs" => length(obs),
				"mean" => @sprintf("%.2f", mean(obs)),
				"std"  => @sprintf("%.2f", std(obs)),
				"max"  => @sprintf("%.2f", maximum(obs)),
				"min"  => @sprintf("%.2f", minimum(obs)),
				"miss" => @sprintf("%.2f", (c_miss / c_obs) * 100),
			),
		)
		if ((i + 1) % 54 == 0)
			push!(preprocessing_dict["descriptive"], Dict("name" => false))
		end
	end

	if "seasonaladjustment" in keys(preprocessing_dict) && preprocessing_dict["seasonaladjustment"] !== nothing
		preprocessing_dict["seasonaladjustment"] = get_array_details(preprocessing_dict["seasonaladjustment"])
	end
	dict[string(Preprocessing.PREPROCESSING_EXTRAKEY)] = preprocessing_dict

	# FeatureExtraction
	if FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY in keys(data.extras)
		data.extras[FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY]
		featureextraction_dict = process_dict(data.extras[FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY])
		if "fe_lag" in keys(featureextraction_dict)
			featureextraction_dict["fe_lag"] = get_array_details(featureextraction_dict["fe_lag"])
		end
		if "fe_log" in keys(featureextraction_dict)
			featureextraction_dict["fe_log"] = replace(string(featureextraction_dict["fe_log"]), "Symbol" => "")
		end
		if "fe_inv" in keys(featureextraction_dict)
			featureextraction_dict["fe_inv"] = replace(string(featureextraction_dict["fe_inv"]), "Symbol" => "")
		end
		if "fe_sqr" in keys(featureextraction_dict)
			featureextraction_dict["fe_sqr"] = replace(string(featureextraction_dict["fe_sqr"]), "Symbol" => "")
		end
		if "interaction" in keys(featureextraction_dict)
			featureextraction_dict["interaction"] =
				get_array_simple_details(featureextraction_dict["interaction"])
		end
		if !("fe_lag" in keys(featureextraction_dict)) &&
		   !("fe_log" in keys(featureextraction_dict)) &&
		   !("fe_inv" in keys(featureextraction_dict)) &&
		   !("fe_sqr" in keys(featureextraction_dict)) &&
		   !("interaction" in keys(featureextraction_dict))
			featureextraction_dict = false
		end
		dict[string(FeatureExtraction.FEATUREEXTRACTION_EXTRAKEY)] = featureextraction_dict
	end

	# PreliminarySelection
	if PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY in keys(data.extras)
		dict[string(PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)] = process_dict(data.extras[PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY])

		betas = dict[string(PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)]["lassobetas"]
		betas_dict = []
		for (i, beta) in enumerate(filter(j -> j != 0, betas))
			if (beta != 0)
				push!(betas_dict, Dict("name" => replace(string(data.expvars[i]), "_" => "\\_"), "coef" => @sprintf("%.3f", beta)))
			end
		end

		dict[string(PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)]["lassolambda"] =
			@sprintf("%.3f", dict[string(PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)]["lassolambda"])

		dict[string(PreliminarySelection.PRELIMINARYSELECTION_EXTRAKEY)]["expvssars"] = betas_dict
	end

	# Output
	if Output.OUTPUT_EXTRAKEY in keys(data.extras)
		dict[string(Output.OUTPUT_EXTRAKEY)] = process_dict(data.extras[Output.OUTPUT_EXTRAKEY])
	end

	return dict
end

"""
Generates latex file with all subset regression result.
# Arguments
- `dict::Dict`: TODO add definition.
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `originaldata::String: the original model selection data.
- `result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult: all subset regression result.
"""
function latex!(
	dict::Dict,
	data::ModelSelection.ModelSelectionData,
	originaldata::ModelSelection.ModelSelectionData,
	result::ModelSelection.AllSubsetRegression.AllSubsetRegressionResult,
)
	if ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY in keys(data.extras)
		dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)] = process_dict(data.extras[ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY])

		if "fixedvariables" in keys(dict) && size(dict["fixedvariables"], 1) == 0
			delete!(dict["fixedvariables"])  # FIXME: This should not be working
		end

		datanames_index = ModelSelection.create_datanames_index(result.datanames)
		cols = ModelSelection.get_selected_variables(Int64(result.bestresult_data[datanames_index[:index]]), data.expvars, data.intercept)

		# FIXME What?? modelavg_datanames = ModelSelection.AllSubsetRegression.get_varnames(result.modelavg_datanames)

		d_bestmodel = Dict()
		d_bestmodel["depvar"] = data.depvar
		d_bestmodel["bmexpvars"] = []

		for var in data.expvars
			intercept = if (data.intercept)
				1
			else
				0
			end
			d = Dict()
			d["name"] = replace(string(var), "_" => "\\_")
			d["nobs"] = result.nobs
			d["criteria"] = result.criteria

			if (var in data.expvars[cols] && !isnan(result.bestresult_data[datanames_index[Symbol("$(var)_b")]]))
				d["best"] = Dict()
				d["best"]["b"] = @sprintf("%.3f", result.bestresult_data[datanames_index[Symbol("$(var)_b")]])
				if (result.ttest)
					d["best"]["ttest"] = true
					d["best"]["bstd"] = @sprintf("%.3f", result.bestresult_data[datanames_index[Symbol("$(var)_bstd")]])
					t = result.bestresult_data[datanames_index[Symbol("$(var)_t")]]
					prob_t = pdf(TDist(data.nobs - length(data.expvars) - (
						if data.intercept
							1
						else
							0
						end
					)), t)
					if (prob_t < 0.01)
						d["best"]["stars"] = "***"
					else
						if (prob_t < 0.05)
							d["best"]["stars"] = "**"
						else
							if (prob_t < 0.1)
								d["best"]["stars"] = "*"
							else
								d["best"]["stars"] = ""
							end
						end
					end
				end
			end

			if (result.modelavg && !isnan(result.modelavg_data[datanames_index[Symbol("$(var)_b")]]))
				d_bestmodel["modelavg"] = true
				d["avg"] = Dict()
				d["avg"]["b"] = @sprintf("%.3f", result.modelavg_data[datanames_index[Symbol("$(var)_b")]])
				if (result.ttest)
					d["avg"]["ttest"] = true
					d["avg"]["bstd"] = @sprintf("%.3f", result.modelavg_data[datanames_index[Symbol("$(var)_bstd")]])
					t = result.modelavg_data[datanames_index[Symbol("$(var)_t")]]
					prob_t = pdf(TDist(data.nobs - length(data.expvars) - (
						if data.intercept
							1
						else
							0
						end
					)), t)
					if (prob_t < 0.01)
						d["avg"]["stars"] = "***"
					else
						if (prob_t < 0.05)
							d["avg"]["stars"] = "**"
						else
							if (prob_t < 0.1)
								d["avg"]["stars"] = "*"
							else
								d["avg"]["stars"] = ""
							end
						end
					end
				end
			end

			if ("best" in keys(d) || "avg" in keys(d))
				push!(d_bestmodel["bmexpvars"], d)
			end
		end

		expvars_dict = map(
			var -> begin
				t = result.data[:, ModelSelection.get_column_index(Symbol("$(var)_t"), result.datanames)]
				b = result.data[:, ModelSelection.get_column_index(Symbol("$(var)_b"), result.datanames)]

				t_nnan = filter(x -> !isnan(x), t)
				b_nnan = filter(x -> !isnan(x), b)

				t_poscol = filter(x -> x > 0, t_nnan)
				b_poscol = filter(x -> x > 0, b_nnan)

				prob_t = map(it -> pdf(TDist(data.nobs - length(data.expvars) - (
					if data.intercept
						1
					else
						0
					end
				)), it), t)
				Dict(
					"name" => var,
					"posshare" => @sprintf("%.3f", size(b_poscol, 1) / size(b_nnan, 1)),
					"sigshare" => @sprintf("%.3f", size(filter(p -> p < 0.1, prob_t), 1) / size(b_nnan, 1)),
					"t" => get_col_statistics(t),
					"b" => get_col_statistics(b),
				)
			end, data.expvars)

		dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["expvars"] = expvars_dict
		dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["expvarswithoutcons"] =
			filter(x -> x["name"] != :_cons, expvars_dict)
		dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["bestmodel"] = d_bestmodel

		if dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["criteria"] != nothing
			dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["criteria"] =
				string("[:", join(dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["criteria"], ", :"), "]")
		end

		if dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["residualtest"] != false
			if "time" in keys(dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]) &&
			   dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["time"] != nothing
				dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["residualtestfortex2"] = true
			else
				dict[string(ModelSelection.AllSubsetRegression.ALLSUBSETREGRESSION_EXTRAKEY)]["residualtestfortex"] = true
			end
		end
	end
	return dict
end

"""
Generates latex file with cross validation result.
# Arguments
- `dict::Dict`: TODO add definition.
- `data::ModelSelection.ModelSelectionData`: the model selection data.
- `originaldata::String: the original model selection data.
- `result::ModelSelection.CrossValidation.CrossValidation: cross validation result.
"""
function latex!(
	dict::Dict,
	data::ModelSelection.ModelSelectionData,
	originaldata::ModelSelection.ModelSelectionData,
	result::ModelSelection.CrossValidation.CrossValidationResult,
)
	if ModelSelection.CrossValidation.CROSSVALIDATION_EXTRAKEY in keys(data.extras)
		dict[string(ModelSelection.CrossValidation.CROSSVALIDATION_EXTRAKEY)] =
			process_dict(data.extras[ModelSelection.CrossValidation.CROSSVALIDATION_EXTRAKEY])

		datanames_index = ModelSelection.create_datanames_index(result.datanames)

		d_bestmodel = []

		for var in data.expvars
			d = Dict()
			d["name"] = replace(string(var), "_" => "\\_")
			if (!isnan(result.average_data[datanames_index[Symbol("$(var)_b")]]))
				d["mean"] = Dict()
				d["mean"]["b"] = @sprintf("%.6f", result.average_data[datanames_index[Symbol("$(var)_b")]])
				if (result.ttest)
					d["mean"]["ttest"] = true
					d["mean"]["bstd"] = @sprintf("%.6f", result.average_data[datanames_index[Symbol("$(var)_bstd")]])
					t = result.average_data[datanames_index[Symbol("$(var)_b")]] / result.average_data[datanames_index[Symbol("$(var)_bstd")]]
					d["mean"]["t"] = t
					prob_t = pdf(TDist(data.nobs - length(data.expvars) - (
						if data.intercept
							1
						else
							0
						end
					)), t)
					if (prob_t < 0.01)
						d["mean"]["stars"] = "***"
					else
						if (prob_t < 0.05)
							d["mean"]["stars"] = "**"
						else
							if (prob_t < 0.1)
								d["mean"]["stars"] = "*"
							else
								d["mean"]["stars"] = ""
							end
						end
					end
				end
				d["median"] = Dict()
				d["median"]["b"] = @sprintf("%.6f", result.median_data[datanames_index[Symbol("$(var)_b")]])
				if (result.ttest)
					d["median"]["ttest"] = true
					d["median"]["bstd"] = @sprintf("%.6f", result.median_data[datanames_index[Symbol("$(var)_bstd")]])
					t = result.median_data[datanames_index[Symbol("$(var)_b")]] / result.median_data[datanames_index[Symbol("$(var)_bstd")]]
					d["median"]["t"] = t
					prob_t = pdf(TDist(data.nobs - length(data.expvars) - (
						if data.intercept
							1
						else
							0
						end
					)), t)
					if (prob_t < 0.01)
						d["median"]["stars"] = "***"
					else
						if (prob_t < 0.05)
							d["median"]["stars"] = "**"
						else
							if (prob_t < 0.1)
								d["median"]["stars"] = "*"
							else
								d["median"]["stars"] = "-"
							end
						end
					end
				end
			end

			if ("mean" in keys(d) || "median" in keys(d))
				push!(d_bestmodel, d)
			end
		end

		dict[string(ModelSelection.CrossValidation.CROSSVALIDATION_EXTRAKEY)]["kfoldvars"] = d_bestmodel

		dict[string(ModelSelection.CrossValidation.CROSSVALIDATION_EXTRAKEY)]["outsample"] = Dict(
			"median" => @sprintf("%.6f", result.median_data[datanames_index[:rmseout]]),
			"mean" => @sprintf("%.6f", result.average_data[datanames_index[:rmseout]]),
		)

	end
	return dict
end

"""
TODO: add description.
# Arguments
- `dict::Dict`: TODO add definition.
"""
function process_dict(dict::Dict)
	dict_str = Dict()
	for key in keys(dict)
		key_str = string(key)
		if dict[key] !== nothing
			dict_str[key_str] = dict[key]
		end
	end
	return dict_str
end

"""
Write template based on dict info.
# Arguments
- `dict::Dict`: TODO add definition.
- `destfolder::AbstractString`: destination directory.
"""
function render_latex(dict, destfolder::AbstractString)
	io = open(joinpath(destfolder, "main.tex"), "w")
	render = render_from_file(joinpath(TEX_TEMPLATE_FOLDER, "../tpl.tex"), dict)
	write(io, render)
	close(io)
end

"""
Zip latex files
# Arguments
- `sourcefolder::AbstractString`: source directory.
- `destfolder::AbstractString`: destination directory.
"""
function zip_folder(sourcefolder::AbstractString, destfolder::AbstractString)
	path_separator = Sys.iswindows() ? "\\" : "/"
	compress = true # or false, like you wish
	zdir = ZipFile.Writer(destfolder) 
	for (root, dirs, files) in walkdir(sourcefolder)
    	for file in files
        	filepath = joinpath(root, file)
        	f = open(filepath, "r")
	        content = read(f, String)
        	close(f)
			remdir = sourcefolder * path_separator
        	zippath = replace(filepath, remdir => "")
			zf = ZipFile.addfile(zdir, zippath; method=(compress ? ZipFile.Deflate : ZipFile.Store));
			write(zf, content)
		end
	end
	close(zdir)			
end

# TODO add description
dropnans(res, var) = res.results[findall(x -> !isnan(x), res.results[:, res.header[var]]), res.header[var]]
