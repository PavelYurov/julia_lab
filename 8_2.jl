function next_repit!(p::Vector{T}, n::T) where T<:Integer
    i = findlast(x->(x < n), p)
    isnothing(i) && (return nothing)
    p[i] += 1
    p[i+1:end] .= 1
    return p
end

function all_repit( m::Int, n::Int; base = 1:m, Type = Int64)
  answer =[]
  for i in 0:(n^m - 1)
    push!(answer,base[reverse(digits(Type,i; base = n, pad = m)) .+ Type(1)])
  end
  return answer
end

function next_permute!(p::AbstractVector)
    n = length(p)
    k = firstindex(p) - 1
    for i in reverse(firstindex(p):lastindex(p) - 1)
        if p[i] < p[i + 1]
            k = i
            break
        end
    end
    k == firstindex(p) - 1 && return nothing
    i = k + 1
    while i < lastindex(p) && p[i + 1] > p[k]
        i += 1
    end
    p[k], p[i] = p[i], p[k]
    reverse!(@view p[k + 1:end])
    return p
end

function all_permute!(a::AbstractArray)
  println(a)
  tmp = next_permute!(a)
  if !isnothing(tmp)
    all_permute(tmp)
  end
end

function all_subsets(a::AbstractArray)
  answer =[]
  tmp = all_repit(length(a),2;base = [false true])
  for i in tmp
    push!(answer,a[findall(i)])
  end
  return answer
end

#indicator(i::Integer, n::Integer) = reverse(digits(Bool, i; base=2, pad=n))

function next_indicator!(indicator::AbstractVector{Bool})
i = findlast(x->(x==0), indicator)
isnothing(i) && return nothing
indicator[i] = 1
indicator[i+1:end] .= 0
return indicator
end

function next_permute_ind!(ind::AbstractVector{Bool})
  i=lastindex(ind)
  while ind[i]==0
    i-=1
  end
  m=0;
  while i >= firstindex(ind) && ind[i]==1
    m+=1
    i-=1
  end
  if i < firstindex(ind)
    return nothing
  end
  ind[i]=1
  @views ind[i+1:end] .= 0
  @views ind[end-m+2:end] .= 1
  return ind
end

function next_split!(s::AbstractVector{Int}, k)
k == 1 && return (nothing, 0)
i = k-1
while i > 1 && s[i-1]==s[i]
i -= 1
end
s[i] += 1
r = sum(@view(s[i+1:k]))
k = i+r-1
s[(i+1):end] .= 1
return s, k
end

abstract type AbstractCombinObject
end
Base.iterate(obj::AbstractCombinObject) = (get(obj), nothing)
Base.iterate(obj::AbstractCombinObject, state) =
if isnothing(next!(obj))
nothing
else
(get(obj), nothing)
end

struct RepitPlacement{N,K} <: AbstractCombinObject
value::Vector{Int}
RepitPlacement{N,K}() where {N, K} = new(ones(Int, K))
end
Base.get(p::RepitPlacement) = p.value
next!(p::RepitPlacement{N,K}) where {N, K} = next_repit!(p.value, N)

struct PermutePlacement{N} <: AbstractCombinObject
  value::Vector{Int}
  PermutePlacement{N}() where N = new(1:N)
end
Base.get(p::PermutePlacement) = p.value
next!(p::PermutePlacement{N}) where N = next_permute!(p.value)

struct IndicatorPlacement{N} <: AbstractCombinObject
  value::Vector{Bool}
  IndicatorPlacement{N}() where N = new(zeros(Bool,N))
end
Base.get(p::IndicatorPlacement) = p.value
next!(p::IndicatorPlacement{N}) where N = next_indicator!(p.value)

struct PermuteIndicatorPlacement{N,T} <: AbstractCombinObject
  value::Vector{Bool}
  PermuteIndicatorPlacement{N,T}() where {N,T} = new(vcat(zeros(Bool,N-T),ones(Bool,T)))
end
Base.get(p::PermuteIndicatorPlacement) = p.value
next!(p::PermuteIndicatorPlacement{N}) where N = next_permute_ind!(p.value)

mutable struct SplitPlacement{N} <: AbstractCombinObject
  value::Vector{Int64}
  k::Int64
  SplitPlacement{N}() where N = new(ones(Int64,N),N)
end
Base.get(p::SplitPlacement) = p.value[1:p.k]
function next!(p::SplitPlacement{N}) where N
  tmp, p.k = next_split!(p.value,p.k)
  isnothing(tmp) && return tmp
  return tmp[1:(p.k)]
end

a = [1,2,3,4]
z = [1, 1, 1, 1,1,1,1]
p = [false, false,false, true, true, true]
# b = all_repit(3,length(a); base = a)
# display(b)
# all_permute!(a)
# display(all_subsets(a))
#display(next_indicator!([true,false,false,true]))
# while(true)
#   tmp = next_permute_ind!(p)
#   isnothing(tmp) && break
#   println(tmp)
# end

# while(true)
#   tmp = next_split!(z,length(z))
#   isnothing(tmp) && break
#   println(tmp)
# end

# k = length(z)
# while !isnothing(z)
#   println(z[1:k])
#   global z, k = next_split!(z, k)
# end

# for a in RepitPlacement{5,2}()
# println(a)
# end

# for a in PermutePlacement{4}()
# println(a)
# end

# for a in IndicatorPlacement{3}()
# println(a)
# end

# for a in PermuteIndicatorPlacement{6,3}()
# println(a)
# end

# for a in SplitPlacement{5}()
# println(a)
# end
