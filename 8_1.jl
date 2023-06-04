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

indicator(i::Integer, n::Integer) = reverse(digits(Bool, i; base=2, pad=n))

function next_indicator!(indicator::AbstractVector{Bool})
i = findlast(x->(x==0), indicator)
isnothing(i) && return nothing
indicator[i] = 1
indicator[i+1:end] .= 0
return indicator
end

# function next_permute_ind!(ind::::AbstractVector{Bool})
#   k = findlast(x->(x == false), ind)
#   if k != lastindex(ind)
#     arr[k],arr[k+1] = arr[k+1],arr[k]
#     return ind
#   end
#   k = -1
#   for i in firstindex(ind):lastindex(ind)-1
#     if arr[i] == 0 && arr[i+1] == 1
#       k = i
#     end
#   end
# end

# function next_permute_ind!(ind::AbstractVector{Bool})
#   i=lastindex(ind)
#   while ind[i]==0
#     i-=1
#   end
#   m=0;
#   while i >= firstindex(ind) && ind[i]==1
#     m+=1
#     i-=1
#   end
#     if i < firstindex(ind)
#     return nothing
#   end
#   ind[i+1]==1
#   ind[i]=1
#   ind[i+1:i+m-1] .= 0
#   ind[i+m:end] .= 1
#   return ind
# end

function next_permute_ind!(ind::AbstractVector{Bool})
  return next_permute!(ind)
end

a = [1,2,3,4]
p = [false,false,false,false,false,true,true,true,true]
# b = all_repit(3,length(a); base = a)
# display(b)
# all_permute!(a)
display(all_subsets(a))
#display(next_indicator!([true,false,false,true]))
# while(true)
#   tmp = next_permute_ind!(p)
#   isnothing(tmp) && break
#   println(tmp)
# end


