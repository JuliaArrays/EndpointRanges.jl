using EndpointRanges
using Base.Test

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
          range(1,2,20),      # StepRange
          1.0:2.0:39.0,       # FloatRange
          linspace(1,100,20), # LinSpace
          collect(1:20),
          view(0:21, 2:21))
    @test a[ibegin:20] == a[1:20]
    @test a[1:iend]    == a[1:20]
    @test a[ibegin+2:iend-3] == a[3:17]
    @test a[ibegin+2:iend÷2] == a[3:10]
    @test a[2*ibegin+1:iend÷2] == a[3:10]
    @test a[1:(ibegin+iend)÷2] == a[1:10]
    @test view(a, 1:(ibegin+iend)÷2) == view(a, 1:10)
    @test view(a, ibegin+2:iend-3) == view(a, 3:17)
end
