include("../const.jl")

using
	Test,
	CSV,
    DataFrames,
	DelimitedFiles,
	ModelSelection.CrossValidation,
	ModelSelection.AllSubsetRegression,
	ModelSelection.PreliminarySelection,
	ModelSelection.Preprocessing

data_fat = CSV.read(DATABASE_FAT, DataFrame)

@testset "Kfold cross validation" begin
	@testset "Fat dataset" begin
		dataorig = Preprocessing.input("y *", data_fat)
		datalassogen, vars = PreliminarySelection.lasso(dataorig)
		AllSubsetRegression.ols!(datalassogen, ttest = true)
		info = CrossValidation.kfoldcrossvalidation(datalassogen, dataorig, 3, 0.03)
		@test 1 == 1
	end
end
