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


#===================================================================#
#===================================================================#
#===================================================================#
#===================================================================#
#===================================================================#

function dfs(graf::Dict{T,Vector{T}},start::T; func::Function = display) where T
  mark = []
  stack = []
  push!(stack,start)
  while length(stack) > 0
    tmp = pop!(stack)
    if !(tmp in mark)
      func(tmp)
      push!(mark,tmp)
      for i in graf[tmp]
        push!(stack,i)
      end
    end
  end
end

function bfs(graf::Dict{T,Vector{T}},start::T; func::Function = display) where T
  mark = []
  queue = []
  push!(queue,start)
  while length(queue) > 0
    tmp = popfirst!(queue)
    if !(tmp in mark)
      func(tmp)
      push!(mark,tmp)
      for i in graf[tmp]
        push!(queue,i)
      end
    end
  end
end



function isconnected(graf::Dict{T,Vector{T}}) where T
  storage = []
  function marker(a::T) where T
    push!(storage,a)
  end
  dfs(graf,collect(keys(graf))[1];func = marker)
  return length(storage) == length(graf)
end

function is_in(a::T,arr) where T
  for i in arr
    if a in i
      return true
    end
  end
  return false
end

function find_components(graf::Dict{T,Vector{T}}) where T
  comp = []
  for i in collect(keys(graf))
    if !(is_in(i,comp))
      storage = []
      function marker(a::T) where T
        push!(storage,a)
      end
      dfs(graf,i;func = marker)
      push!(comp,storage)
    end
  end
  return comp
end

function isBipartite(graf::Dict{T,Vector{T}}) where T
  !(isconnected(graf)) && return false
  Bipart = true
  color = Dict{T,Int64}(collect(keys(graf))[1] => 1)
  function draw(a::T)
    tmp = collect(keys(color))
    for i in graf[a]
      if i in tmp
        if (color[i] != (color[a] * -1))
          Bipart = false
        end
      else
        merge!(color,Dict(i => (-1 * color[a])))
      end
    end
  end
  dfs(graf,collect(keys(graf))[1];func = draw)
  return Bipart
end


graf1 = Dict(1=>[2,3],2=>[3,1],3=>[1,2,4],4=>[3,5],5=>[4,6,8],6=>[5],8=>[5,10], 9=>[10],10=>[9,11,8],11=>[9,12,13],12=>[11],13=>[11])

graf2 = Dict(1 => [2,4],2 => [1,3],3=>[2,4],4=>[1,3,5],5=>[4])

# dfs(graf1,1)
# println(" ")
# bfs(graf1,1)
# display(isconnected(graf1))
# display(find_components(graf1))
# display(isBipartite(graf2))
