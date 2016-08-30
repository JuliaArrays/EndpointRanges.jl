# EndpointRanges

[![Build Status](https://travis-ci.org/JuliaArrays/EndpointRanges.jl.svg?branch=master)](https://travis-ci.org/JuliaArrays/EndpointRanges.jl)

[![codecov.io](http://codecov.io/github/JuliaArrays/EndpointRanges.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaArrays/EndpointRanges.jl?branch=master)

This Julia package makes it easier to index "unconventional" arrays
(ones for which indexing does not necessarily start at 1), by defining
constants `ibegin` and `iend` that stand for the beginning and end,
respectively, of the indices range along any given dimension.

# Usage

```jl
using EndpointRanges

a = 1:20
a[ibegin:iend] == a
a[ibegin+3:iend-2] == a[4:18]
a[1:(ibegin+iend)÷2] == a[1:10]
```

Note that, unlike `3:end` you can also pass such indices as arguments to a function:
```
view(a, ibegin+2:iend-3) == view(a, 3:17)
```
