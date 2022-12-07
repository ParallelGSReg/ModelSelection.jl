include("../const.jl")

using
    Test,
    CSV,
    DataFrames,
    DelimitedFiles,
    ModelSelection

data_small = CSV.read(DATABASE_SMALL, DataFrame)

@testset "AllSubsetRegression" begin
    @testset "With T-test" begin
        res = gsr("y x*", data_small, ttest=true)
        @test 1 == 1
    end
end
