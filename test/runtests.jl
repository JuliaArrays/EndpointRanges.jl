using EndpointRanges
using Test

@testset "One dimensional" begin
    r1 = -3:7
    r2 = 2:5
    @test ibegin(r1) == -3
    @test ibegin(r2) == 2
    @test iend(r1) == 7
    @test iend(r2) == 5

    @test (ibegin+3)(r1) == 0
    @test (ibegin+2)(r2) == 4
    @test (iend+3)(r1) == 10
    @test (iend-2)(r2) == 3

    for a in (1:20,
              range(1,step=2,length=20),
              1.0:2.0:39.0,
              range(1,stop=100,length=20),
              collect(1:20),
              view(0:21, 2:21))
        @test a[ibegin] == a[1]
        @test a[iend]   == a[end]
        @test a[ibegin+1] == a[2]
        @test a[iend-1]   == a[end-1]
        @test_throws BoundsError a[ibegin-1]
        @test_throws BoundsError a[iend+1]
        @test a[ibegin:20] == a[1:20]
        @test a[1:iend]    == a[1:20]
        @test a[ibegin+2:iend-3] == a[3:17]
        @test a[ibegin+2:iend÷2] == a[3:10]
        @test a[2*ibegin+1:iend÷2] == a[3:10]
        @test a[1:(ibegin+iend)÷2] == a[1:10]
        @test view(a, 1:(ibegin+iend)÷2) == view(a, 1:10)
        @test view(a, ibegin+2:iend-3) == view(a, 3:17)
    end

    # issue #8
    a = 1:9
    @test a[ibegin] == 1
    @test a[iend] == 9
    # issue #10
    @test a[ibegin:3:iend] == 1:3:7
end

@testset "Multidimensional" begin
    # issue #3
    A = reshape(1:12, (3, 4))
    @test A[ibegin:2, 2:iend] == A[1:2, 2:4]

    A = reshape(1:20, 4, 5)
    @test A[2,ibegin]   == 2
    @test A[2,ibegin+1] == 6
    @test A[3,iend-1]   == 15
    @test A[ibegin+1,iend-1] == 14
end
