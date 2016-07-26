module EndpointRanges

import Base: +, -, *, /, ÷, %
using Base: LinearIndexing, ViewIndex, tail, indices1

export ibegin, iend

abstract Endpoint
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
abstract EndpointRange{T}
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

function Base.getindex(r::FloatRange, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end

function Base.getindex(r::LinSpace, s::EndpointRange)
    getindex(r, newindex(indices1(r), s))
end

@inline function Base._getindex{T,N}(l::LinearIndexing, A::AbstractArray{T,N}, I::Vararg{Union{Real, AbstractArray, Colon, EndpointRange},N})
    Base._getindex(l, A, newindices(indices(A), I)...)
end

@inline function Base.view{T,N}(A::AbstractArray{T,N}, I::Vararg{Union{ViewIndex,EndpointRange},N})
    view(A, newindices(indices(A), I)...)
end

@inline newindices(indsA, inds) = (newindex(indsA[1], inds[1]), newindices(tail(indsA), tail(inds))...)
newindices(::Tuple{}, ::Tuple{}) = ()

newindex(indA, i::Union{Real, AbstractArray, Colon}) = i
newindex(indA, i::EndpointRange) = i(indA)

end # module
