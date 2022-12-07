mutable struct AllSubsetRegressionResult <: ModelSelection.ModelSelectionResult
	datanames::Vector{Symbol}
	modelavg_datanames::Any

	data::Any
	bestresult_data::Any
	modelavg_data::Any

	fixedvariables::Any
	outsample::Any
	criteria::Any
	modelavg::Any
	ttest::Any
	residualtest::Any
	orderresults::Any
	nobs::Any

	function AllSubsetRegressionResult(
		datanames,
		modelavg_datanames,
		fixedvariables,
		outsample,
		criteria,
		modelavg,
		ttest,
		residualtest,
		orderresults,
	)
		new(datanames, modelavg_datanames, nothing, nothing, nothing, fixedvariables, outsample, criteria, modelavg, ttest, residualtest, orderresults, 0)
	end
end
