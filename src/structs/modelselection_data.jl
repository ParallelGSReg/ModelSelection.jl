mutable struct ModelSelectionData
	equation::Array{Symbol}
	depvar::Symbol
	expvars::Array{Symbol}
	time::Union{Symbol, Nothing}
	panel::Union{Symbol, Nothing}
	depvar_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float64, Missing}}, Vector{Union{Float32, Missing}}}
	expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float64, Missing}}, Array{Union{Float32, Missing}}}
	time_data::Union{Nothing, Vector{Float64}, Vector{Float32}, Vector{Union{Float64, Missing}}, Vector{Union{Float32, Missing}}}
	panel_data::Union{Nothing, Vector{Int64}, Vector{Int32}, Vector{Union{Int64, Missing}}, Vector{Union{Int32, Missing}}}
	intercept::Bool
	datatype::DataType
	removemissings::Bool
	nobs::Int64
	options::Array{Any}
	extras::Dict
	previous_data::Array{Any}
	results::Array{Any}

	function ModelSelectionData(
		equation::Vector{Symbol},
		depvar::Symbol,
		expvars::Vector{Symbol},
		time::Union{Symbol, Nothing},
		panel::Union{Symbol, Nothing},
		depvar_data::Union{Vector{Float64}, Vector{Float32}, Vector{Union{Float32, Missing}}, Vector{Union{Float64, Missing}}},
		expvars_data::Union{Array{Float64}, Array{Float32}, Array{Union{Float32, Missing}}, Array{Union{Float64, Missing}}},
		time_data::Union{Nothing, Vector{Float64}, Vector{Float32}, Vector{Union{Float64, Missing}}, Vector{Union{Float32, Missing}}},
		panel_data::Union{Nothing, Vector{Int64}, Vector{Int32}, Vector{Union{Int64, Missing}}, Vector{Union{Int32, Missing}}},
		intercept::Bool,
		datatype::DataType,
		removemissings::Bool,
		nobs::Int64,
	)
		extras = Dict()
		options = Array{Any}(undef, 0)
		previous_data = Array{Any}(undef, 0)
		results = Array{Any}(undef, 0)
		new(equation, depvar, expvars, time, panel, depvar_data, expvars_data, time_data, panel_data, intercept, datatype, removemissings, nobs, options, extras, previous_data, results)
	end
end
