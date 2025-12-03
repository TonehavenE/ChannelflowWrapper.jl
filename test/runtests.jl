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


    @time @testset "L2op" begin
        # Compute L2 distance between a field and itself (should be 0)
        dist = L2op("../data/uTW2-2pi1piRe250.nc", "../data/uTW2-2pi1piRe250.nc"; dist=true)
        @test dist ≈ 0.0 atol = 1e-10

        # Compute L2 inner product
        ip = L2op("../data/uTW2-2pi1piRe250.nc", "../data/EQ7Re250-32x49x40.nc"; ip=true)
        @test ip isa Float64

        # Compute L2 distance between two different fields
        dist2 = L2op("../data/uTW2-2pi1piRe250.nc", "../data/EQ7Re250-32x49x40.nc"; dist=true)
        @test dist2 > 0.0
    end

    @time @testset "diffop" begin
        # Compute gradient
        diffop("../data/uTW2-2pi1piRe250.nc", "grad_output.nc"; grad=true)
        @test isfile("grad_output.nc")

        # Compute laplacian
        diffop("../data/uTW2-2pi1piRe250.nc", "lapl_output.nc"; lapl=true)
        @test isfile("lapl_output.nc")

        # Compute divergence
        diffop("../data/uTW2-2pi1piRe250.nc", "div_output.nc"; div=true)
        @test isfile("div_output.nc")

        # Compute streamwise average
        diffop("../data/uTW2-2pi1piRe250.nc", "xavg_output"; xavg=true)
        @test isfile("xavg_output_xavg.nc")
    end


    @time @testset "addfields and addbaseflow" begin
        # Linear combination: 0.5*field1 + 0.5*field2
        addfields("combo_output.nc",
            0.5 => "../data/uTW2-2pi1piRe250.nc",
            0.5 => "../data/EQ7Re250-32x49x40.nc")
        @test isfile("combo_output.nc")

        # Add baseflow to a field
        addbaseflow("../data/uTW2-2pi1piRe250.nc", "with_baseflow.nc";
            bf="laminar", R=250)

        @test isfile("with_baseflow.nc")
    end

    @time @testset "findsymmetries" begin
        # Find symmetries of a field (just checking it runs without error)
        findsymmetries("../data/uTW2-2pi1piRe250.nc"; nx=4, nz=4)

        # Check antisymmetries as well
        findsymmetries("../data/EQ7Re250-32x49x40.nc"; a=true)
    end

    cd("..")
    rm("sandbox", recursive=true)
end
