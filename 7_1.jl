using LinearAlgebra
 
Vector2D{T<:Real} = NamedTuple{(:x,:y), Tuple{T,T}}
 
Base. +(a::Vector2D{T},b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .+ Tuple(b))
 
Base. -(a::Vector2D{T},b::Vector2D{T}) where T = Vector2D{T}(Tuple(a) .- Tuple(b))
 
Base. *(a::T,b::Vector2D{T}) where T = Vector2D{T}(a .*Tuple(b))
p1 = (x=0,y=0)
p2 = (x=1,y=1)
a = (x = 0, y = 1)
b = (x = 1, y = 0)
 
LinearAlgebra.norm(a::Vector2D) = norm(Tuple(a))
 
LinearAlgebra.dot(a::Vector2D{T},b::Vector2D{T}) where T =  dot(Tuple(a),Tuple(b))
 
Base. cos(a::Vector2D{T},b::Vector2D{T}) where T = dot(a,b)/norm(a)/norm(b)
 
xdot(a::Vector2D{T},b::Vector2D{T}) where T = a.x * b.y - a.y*b.x
 
Base. sin(a::Vector2D{T},b::Vector2D{T}) where T = xdot(a,b) / norm(a) / norm(b)
Base.angle(a::Vector2D{T},b::Vector2D{T}) where T = atan(sin(a,b)/cos(a,b))
Base.sign(a::Vector2D{T},b::Vector2D{T}) where T =  sign(sin(a,b))
angle_new(a::Vector2D{T},b::Vector2D{T}) where T = acos(cos(a,b))
 
Segment2D{T<:Real} = NamedTuple{(:A,:B),NTuple{2,Vector2D{T}}}
 
on_one_side(a::Vector2D{T}, b::Vector2D{T}, line::Segment2D{T}) where T = sign(line.B - a,line.A - line.B) == sign(line.B - b,line.A - line.B)
on_one_side(a::Vector2D{T}, b::Vector2D{T}, func::Function) where T = (func(a...) * func(b...)) > 0
 
# function isconvex(arr::Array{Vector2D{T}}) where T
#     if length(arr) <= 3
#         return true
#     end
#     s = sign(arr[2] - arr[1], arr[3] - arr[2])
#     display(arr[2] - arr[1])
#     display(s)
#     v =  arr[3] - arr[2]
#     display(v)
#     for i in 4:length(arr)
#         s1, v = sign(v,arr[i]), arr[i] - arr[i-1]
#         display(v)
#         display(s1)
#         if s1*s < 0
#             return false
#         end
#         s1 = s
#     end
#     return (s * sign(v,arr[1] - arr[end])) >= 0
# end
 
function isconvex(arr::Array{Vector2D{T}}) where T
    if length(arr) <= 3
        return true
    end
    s = 0
    v = arr[2] - arr[1]
    for i in 3:length(arr)
        v1 = arr[i] - arr[i-1]
        s1 = sign(v,v1)
        # println(" ")
        # display(s1)
        # display(s)
        # display(s*s1)
 
        if s*s1 < 0
            return false
        end
        if s1 != 0
            s += s1 - s
        end
        v = v1
    end
    # display(sign(v,arr[1] - arr[end]))
    # display(s*sign(v,arr[1] - arr[end]))
    return s*sign(v,arr[1] - arr[end]) >= 0
end
 
 
function innerpoint(a::Vector2D{T}, arr::Array{Vector2D{T}}) where T
    sum = 0
    for i in 2:length(arr)
        sum += angle(arr[i]-a,arr[i-1] - a)
    end
    sum += angle(arr[1] - a,arr[end] -a)
    return !((abs(sum) - pi ) < 1e-8)
end

#=function crosline(a::Segment2D{T}. b::Segment2D{T}) where T
  if !on_one_side(a.A,a.B,b) && !on_one_side(b.A,b.B,a)
    
  else
    return (x = NaN, y = NaN)
  end
end=#

function intersect(s1::Segment2D{T},s2::Segment2D{T}) where T
 A = [s1.B[2]-s1.A[2] s1.A[1]-s1.B[1]
  s2.B[2]-s2.A[2] s2.A[1]-s2.B[1]]
 b = [s1.A[2]*(s1.A[1]-s1.B[1]) + s1.A[1]*(s1.B[2]-s1.A[2])
  s2.A[2]*(s2.A[1]-s2.B[1]) + s2.A[1]*(s2.B[2]-s2.A[2])]
  x,y = A\b
 # !!!! Если матрица A - вырожденная, то произойдет ошибка времени выполнения
 if isinner((;x, y), s1)==false || isinner((;x, y), s2)==false
 return nothing
 end
 return (;x, y) #Vector2D{T}((x,y))
end

isinner(P::Vector2D, s::Segment2D) =
 (s.A.x <= P.x <= s.B.x || s.A.x >= P.x >= s.B.x) &&
 (s.A.y <= P.y <= s.B.y || s.A.y >= P.y >= s.B.y)

function comp(a::Vector2D{W}, b::Vector2D{W},T::Vector2D{W}) where W
  return angle(a-T,(x=1.0,y=0.0)) < angle(b-T,(x=1.0,y=0.0))
end

function q_sort!(arr, p::Vector2D{T}) where T
    n= length(arr)
    middle = arr[div(n,2)]
    i = 1; j = n;
    @inbounds while i <= j
        @inbounds while comp(arr[i], middle,p)
            i+=1
        end
        @inbounds while  comp(middle,arr[j],p)
            j-=1
        end
        if(i <= j)
            @inbounds arr[i],arr[j] = arr[j],arr[i]
            i+=1; j-=1
        end
    end
    if j> 1
        @inbounds @views q_sort!(arr[1:j],p)
    end
    if i < n
        @inbounds @views q_sort!(arr[i:end],p)
    end
end

function JarvisMarch(P::Array{Vector2D{T}}) where T
  @views sort!(P[1:end]);
  @views q_sort!(P[2:end],P[1]);
  tmp = [P[1],P[2]]
  for i in P[3:end]
    if(sign(tmp[end]-tmp[end-1], i - tmp[end]) < 0)
      push!(tmp, i)
    else
      pop!(tmp)
      push!(tmp, i)
    end
  end
  return tmp
end

function Gramscan(P::Array{Vector2D{T}}) where T
  #@views sort!(P[1:end]);
  tmp = [minimum(P)]
  tmp_vect = (x=0.0,y=1.0)
  tmp_point = maximum(P)
  for i in P
     if tmp[end] != i && angle_new(tmp_vect,tmp_point - tmp[end]) < angle_new(tmp_vect,i - tmp[end])
        tmp_point = i
    end
  end
  push!(tmp,tmp_point)
  
  while tmp[end] != tmp[1]
    tmp_vect = tmp[end] - tmp[end-1]
    tmp_angle = 3.1415
    for i in P[1:end]
     if tmp[end] != i && tmp_angle > angle_new(tmp_vect,i - tmp[end])
        tmp_point = i
        tmp_angle = angle_new(tmp_vect,i - tmp[end])
      end
    end
  push!(tmp,tmp_point)
  end
  return tmp
end

function area_trap(P::Array{Vector2D{T}}) where T
  #=min = (sort(P[1:end]))[1]
  for i in 1:length(P)
    P[i] -= min
  end=#
  area = 0.0
  for i in 2:length(P)
    area += (P[i].x - P[i-1].x)*(P[i].y+P[i-1].y)/2
  end
  area += (P[1].x - P[end].x)*(P[1].y+P[end].y)/2
  return area
end

function area_tri(P::Array{Vector2D{T}}) where T
  
  area = 0.0
  for i in 2:length(P)
    if(norm(P[i])*norm(P[i-1]) != 0)
      area += norm(P[i])*norm(P[i-1])*sin(P[i-1],P[i])/2
    end
  end
  if(norm(P[1])*norm(P[end]) != 0)
    area += norm(P[1])*norm(P[end])*sin(P[1],P[end])/2
  end
  return area
end

# display(p1 + p2)
# display(p1 - p2)
# display(3*p1)
# display(cos(p1,p2))
# display(sin(p1,p2))
# display(xdot(p1,p2))
# display(angle(p1,p2))
# display(dot(p1,p2))
# display(sign(p1,p2))
#f(x,y) = cos(x) - y
#on_one_side(a,b,(A = p1, B = p2))
#on_one_side(a,b,f)
A = [(x=0.0,y=0.0) (x=1.0,y=0.0) (x=1.0,y=1.0) (x=0.0,y=1.0) (x=0.5,y=0.5) (x=1.0,y=1.5) (x=-1.0,y=1.0) (x=-1.0,y=-1.0)]
B = [(x=0.0,y=0.0) (x=1.0,y=0.0) (x=1.0,y=1.0) (x=1.0,y=1.5) (x=0.0,y=1.0) (x=-1.0,y=1.0) (x=-1.0,y=-1.0)]
#B =reverse(B)
#isconvex(A)
#innerpoint((x = 1.5, y= 0.5),A)
#display(intersect((A = (x = 0.0, y = 0.0), B = (x = 1.0, y = 1.0)),(A = (x = 0.0, y = 1.0), B = (x = 1.0, y = 0.0))))
#@time display(JarvisMarch(A))
#@time display(Gramscan(A))
@time display(area_trap(B))
@time display(area_tri(B))
