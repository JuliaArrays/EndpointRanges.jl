module EndpointRanges

using Compat

import Base: +, -, *, /, ÷, %
using Base: ViewIndex, tail, indices1

export ibegin, iend

@compat abstract type Endpoint end
immutable IBegin <: Endpoint end
immutable IEnd   <: Endpoint end
const ibegin = IBegin()
const iend   = IEnd()

(::IBegin)(b::Integer, e::Integer) = b
(::IEnd  )(b::Integer, e::Integer) = e
(::IBegin)(r::Range) = first(r)
(::IEnd  )(r::Range) = last(r)

immutable IndexFunction{F<:Function} <: Endpoint
    index::F
end
(f::IndexFunction)(r::Range) = f.index(r)

for op in (:+, :-)
    @eval $op(x::Endpoint) = IndexFunction(r->x(r))
end
for op in (:+, :-, :*, :/, :÷, :%)
    @eval $op(x::Endpoint, y::Endpoint) = IndexFunction(r->$op(x(r), y(r)))
    @eval $op(x::Endpoint, y::Number) = IndexFunction(r->$op(x(r), y))
    @eval $op(x::Number, y::Endpoint) = IndexFunction(r->$op(x, y(r)))
end

# deliberately not <: AbstractUnitRange{Int}
@compat abstract type EndpointRange{T} end
immutable EndpointUnitRange{F<:Union{Int,Endpoint},L<:Union{Int,Endpoint}} <: EndpointRange{Int}
    start::F
    stop::L
end

(r::EndpointUnitRange)(s::Range) = r.start(s):r.stop(s)
(r::EndpointUnitRange{Int,E}){E<:Endpoint}(s::Range) = r.start:r.stop(s)
(r::EndpointUnitRange{E,Int}){E<:Endpoint}(s::Range) = r.start(s):r.stop

Base.colon(start::Endpoint, stop::Endpoint) = EndpointUnitRange(start, stop)
Base.colon(start::Endpoint, stop::Int) = EndpointUnitRange(start, stop)
Base.colon(start::Int, stop::Endpoint) = EndpointUnitRange(start, stop)

function Base.getindex(r::UnitRange, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end

function Base.getindex(r::AbstractUnitRange, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end

function Base.getindex(r::StepRange, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end

if VERSION < v"0.6.0-dev.2376"
    function Base.getindex(r::FloatRange, s::EndpointRange)
        getindex(r, newindex(indices1(r), s))
    end
else
    function Base.getindex(r::StepRangeLen, s::EndpointRange)
        getindex(r, newindex(indices1(r), s))
    end
end

function Base.getindex(r::LinSpace, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end

# @inline function Base._getindex{T,N}(l::IndexLinear, A::AbstractArray{T,N}, I::Vararg{Union{Real, AbstractArray, Colon, EndpointRange},N})
#     Base._getindex(l, A, newindices(indices(A), I)...)
# end

if VERSION < v"0.6.0-dev.1932"
    @inline function Base.view{T,N}(A::AbstractArray{T,N}, I::Vararg{Union{ViewIndex,EndpointRange},N})
        view(A, newindices(indices(A), I)...)
    end
else
    @inline function Base.to_indices(A, inds, I::Tuple{EndpointRange, Vararg{Any}})
        (newindex(inds[1], I[1]), to_indices(A, Base._maybetail(inds), Base.tail(I))...)
    end
end

@inline newindices(indsA, inds) = (newindex(indsA[1], inds[1]), newindices(tail(indsA), tail(inds))...)
newindices(::Tuple{}, ::Tuple{}) = ()

newindex(indA, i::Union{Real, AbstractArray, Colon}) = i
newindex(indA, i::EndpointRange) = i(indA)

end # module
