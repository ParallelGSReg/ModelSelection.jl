include("../const.jl")

using Test,
    CSV,
    DataFrames,
    DelimitedFiles,
    ModelSelection.PreliminarySelection,
    ModelSelection.Preprocessing

data_fat = CSV.read(DATABASE_FAT, DataFrame)

@testset "Lasso" begin
    @testset "Fat dataset" begin
        data = Preprocessing.input("y *", data_fat)
        data = PreliminarySelection.lasso(data)
        @test length(data.expvars, 1) < length(data.expvars)
    end
end
