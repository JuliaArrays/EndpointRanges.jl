module EndpointRanges

using Compat

import Base: +, -, *, /, ÷, %
using Base: ViewIndex, tail, indices1

export ibegin, iend

abstract type Endpoint end
struct IBegin <: Endpoint end
struct IEnd   <: Endpoint end
const ibegin = IBegin()
const iend   = IEnd()

(::IBegin)(b::Integer, e::Integer) = b
(::IEnd  )(b::Integer, e::Integer) = e
(::IBegin)(r::AbstractRange) = first(r)
(::IEnd  )(r::AbstractRange) = last(r)

struct IndexFunction{F<:Function} <: Endpoint
    index::F
end
(f::IndexFunction)(r::AbstractRange) = f.index(r)

for op in (:+, :-)
    @eval $op(x::Endpoint) = IndexFunction(r->x(r))
end
for op in (:+, :-, :*, :/, :÷, :%)
    @eval $op(x::Endpoint, y::Endpoint) = IndexFunction(r->$op(x(r), y(r)))
    @eval $op(x::Endpoint, y::Number) = IndexFunction(r->$op(x(r), y))
    @eval $op(x::Number, y::Endpoint) = IndexFunction(r->$op(x, y(r)))
end

# deliberately not <: AbstractUnitRange{Int}
abstract type EndpointRange{T} end
struct EndpointUnitRange{F<:Union{Int,Endpoint},L<:Union{Int,Endpoint}} <: EndpointRange{Int}
    start::F
    stop::L
end

(r::EndpointUnitRange)(s::AbstractRange) = r.start(s):r.stop(s)
(r::EndpointUnitRange{Int,E})(s::AbstractRange) where {E<:Endpoint} = r.start:r.stop(s)
(r::EndpointUnitRange{E,Int})(s::AbstractRange) where {E<:Endpoint} = r.start(s):r.stop

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

function Base.getindex(r::StepRangeLen, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end

function Base.getindex(r::LinSpace, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end


@inline function Base.to_indices(A, inds, I::Tuple{Union{Endpoint, EndpointRange}, Vararg{Any}})
    (newindex(inds[1], I[1]), to_indices(A, Base._maybetail(inds), Base.tail(I))...)
end

@inline newindices(indsA, inds) = (newindex(indsA[1], inds[1]), newindices(tail(indsA), tail(inds))...)
newindices(::Tuple{}, ::Tuple{}) = ()

newindex(indA, i::Union{Real, AbstractArray, Colon}) = i
newindex(indA, i::EndpointRange) = i(indA)
newindex(indA, i::IBegin) = first(indA)
newindex(indA, i::IEnd)   = last(indA)

end # module
