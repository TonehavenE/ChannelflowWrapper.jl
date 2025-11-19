using Test

using ChannelflowWrapper

# These tests are not exhaustive or good. They are just to ensure that things run.

@testset "Channelflow Tests" begin
    mkpath("sandbox")
    cd("sandbox")

    @time @testset "field2coeff and coeff2field" begin
        field2coeff("../data/ijkl-sztx-1-2-2.asc", "../data/uTW2-2pi1piRe250.nc", "tw2-coeffs.asc")
        coeff2field("tw2-coeffs.asc", "../data/ijkl-sztx-1-2-2.asc", "../data/uTW2-2pi1piRe250.nc", "tw2_reproduction.nc")
    end

    @time @testset "findsoln" begin
        findsoln("../data/EQ7Re250-32x49x40.nc"; eqb=true, R=250, T=10)
    end

    @time @testset "changegrid" begin
        changegrid("../data/uTW2-2pi1piRe250.nc", "changegrid_example.nc")
    end

    cd("..")
    rm("sandbox", recursive=true)
end
