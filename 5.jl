#include("1.jl")



function gcp(a::T, b::T) where T <: Int
    while(b!=0)
        a,b = b,mod(a,b)
    end
    return a
end

function egcp(a::T, b::T) where T <: Int
    m,n = a,b
    u , v = 1 , 0;
    u1,v1=0,1
    while(b>0)
        k = div(a,b)
        a,b = b,a-k*b
        u,v,u1,v1 = u1,v1,u-k*u1,v-k*v1
    end
    if a < 0
        a,u,v =-a,-u,-v
    end
    return a,u,v
end
function inverse_null(a::T,n::T) where T<:Int
    if(gcp(a,n) == 1)
        return Nothing
    end
    return div(n,gcp(a,n))
end
function inverse(a::T,n::T) where T<:Int
    if(gcp(a,n) != 1)
        return Nothing
    end
    a,u,v = egcp(mod(a,n),n) #ab = 1 + nm ab - nm = 1
    return mod(u,n)
end
struct Residu{T,M}
    a::T
    Residu{T,M}(b::T)  where{T<:Integer, M} = new(mod(b,M))
end
function get_value(a::Residu{T,M})where {T,M}
    return a.a
end

function Base. +(a::Residu{T,M},b::Residu{T,M})where{T, M}
    return Residu{T,M}(mod(get_value(a)+get_value(b),M))
end

function Base. -(a::Residu{T,M},b::Residu{T,M})where{T, M}
    return Residu{T,M}(mod(get_value(a)-get_value(b),M))
end

function Base. *(a::Residu{T,M},b::Residu{T,M})where{T, M}
    return Residu{T,M}(mod(get_value(a)*get_value(b),M))
end
function inverse(a::Residu{T,M}) where {T,M}
    f = get_value(a)
    d = M
    if(gcp(f,M) != 1)
        return 0
    end
    s1,s2,s3 = egcp(mod(f,M),M)
    return Residu{T,M}(s2) #ab = 1 + nm ab - nm = 1
end

function Base. /(a::Residu{T,M},b::Residu{T,M})where{T, M}
    return a * inverse(b)
end

function Base.print(a::Residu{T,M}) where {T,M}
    print(get_value(a))
end



#================================================================#


function abs(a::Float64)
    return sign(a)*a
end

function Base. *(a::Residu{T,M}, b::Array{Residu{T,M}}) where {T,M}
    c = []
    for i in b[1:end]
        push!(c,i*a)
    end
    return c
end

function Base. isless(a::Residu{T,M}, b::Residu{T,M})where {T,M}
    return (get_value(a) < get_value(b))
end

function Base. ==(a::Residu{T,M}, b::Residu{T,M})where {T,M}
    return(get_value(a) == get_value(b))
end
function Base. !=(a::Residu{T,M}, b::Residu{T,M})where {T,M}
    return(get_value(a) != get_value(b))
end
function Base. >=(a::Residu{T,M}, b::Residu{T,M})where {T,M}
    return(get_value(a) >= get_value(b))
end
function Base. <=(a::Residu{T,M}, b::Residu{T,M})where {T,M}
    return(get_value(a) <= get_value(b))
end
function Base. >(a::Residu{T,M}, b::Residu{T,M})where {T,M}
    return(get_value(a) > get_value(b))
end
function Base. *(a::Residu{T,M}, b::Array{Any})where {T,M}
    c = []
    for i in b[1:end]
        push!(c,a*i)
    end
    return c

end
#================================================================#
mutable struct Polinom
    coef::Array
end

function Base.print(a::Polinom)
    T = typeof(a.coef[1])
    if T(0)*a.coef  == a.coef
        print(0)
        return
    end
    if a.coef[1]!= T(0)
        print(a.coef[1])
    end
    n = 1
    for i in a.coef[2:end]
        if i!= T(0)
            if a.coef[n+1] < T(0)
                print("-")
            elseif (a.coef[n+1] != T(0))
                if !(n == 1 && a.coef[1] == T(0))
                    print("+")
                end
            end
            
            if abs(i) != T(1)
                print(abs(i),"*")
            end
            print("x")
            if(n != 1)
                print("^", n)
            end
        end
        n+=1
    end
end

function abs(a::Residu{T,M}) where {T,M}
    return(sign(get_value(a))*get_value(a))
end

function Base. +(a::Polinom, b::Polinom)
    b_ = b.coef
    a_ = a.coef
    T = typeof(a.coef[1])
    if size(a.coef)[1]>size(b.coef)[1]
        c = Polinom(a.coef)
        for i in size(b.coef)[1]:size(a.coef)[1]-1
            push!(b_,T(0))
        end
    else
        for i in size(a.coef)[1]:size(b.coef)[1]-1
            push!(a_,T(0))
        end
        c = Polinom(b.coef)
    end
    c.coef  = a_ + b_
    normalize(c)
    return c
end

function Base. -(a::Polinom, b::Polinom)
    T = typeof(a.coef[1])
    c = Polinom(T(-1)*b.coef)                                 #!!!!
    return a + c;
end

function normalize(a::Polinom)
    T = typeof(a.coef[1])
    while size(a.coef)[1] > 1 && a.coef[end] == T(0) 
        pop!(a.coef)
    end
end

function dim(a::Polinom)
    normalize(a)
    return size(a.coef)[1]
end

function Base. *(a::Polinom, b::Polinom)
    T = typeof(a.coef[1])
    normalize(a);normalize(b)
    arr = []
    for i in 1:dim(a)+dim(b)
        push!(arr,T(0))
    end
    n = 1
    for i in 1:dim(a)
        for j in 1:dim(b)
            arr[i+j-1] += a.coef[i]*b.coef[j]
        end
    end
    return Polinom(arr)
end
function Base. *(value::T, a::Polinom) where T
    c = Polinom(value * a.coef)
    return c
end

function get_max_pow(value::Int, T)
    arr = []
    for i in 1:value+1
        push!(arr,T(0))
    end
    arr[end] =  T(1)
    return Polinom(arr)
end

function Base. *(a::Residu{T,M},b::Polinom) where {T,M}
    arr = a*b.coef
    return Polinom(arr)
end

function Base. /(a::Polinom, b::Polinom)
    T = typeof(a.coef[1])
    if b == Polinom([T(0)])
        print("деление на 0")
        return T(0)
    end
    ost = a
    chel = Polinom([T(0)])
    #n = 0
    while dim(ost) >= dim(b) && ost.coef[end] != T(0)
        # println(Polinom([ost.coef[end]/b.coef[end]]))
        # println(size(a.coef)[1])
        # println(get_max_pow(dim(ost) - dim(b)))
        chel = chel + Polinom([ost.coef[end]/b.coef[end]])*get_max_pow(dim(ost) - dim(b),T)
        del = ost.coef[end]/b.coef[end]*get_max_pow(dim(ost) - dim(b),T)*b
        #print(del, "\t|#|\t", ost, "\n")
        #println(ost, "\t", del, "\t",get_max_pow(dim(ost) - dim(b)), "\t",dim(ost) - dim(b))
        ost = ost - del
        normalize(ost)
        # if n == 10
        #     return (chel,ost)
        # end
        # n+=1
        normalize(ost)
    end
    return (chel,ost)
end

p1 = Polinom([-6,-1,-2,1])
p2 = Polinom([-3,1])
print(p1/p2)
# a = Polinom([1;13;0;53;44;0])
# b= Polinom([1;23;4;5;25;5;26;23;3])
# println(a*b)
# println(a)
# normalize(a)
# println(a)
R = 7
a1 = Residu{Int,R}(4)
a2 = Residu{Int,R}(3)
a3 = Residu{Int,R}(2)
a4 = Residu{Int,R}(1)
#a5 = Residu{Int,R}(1)
b1 = Residu{Int,R}(1)
#b2 = Residu{Int,R}(3)
#b3 = Residu{Int,R}(1)
a = Polinom([a4,a3,a2,a1])
b = Polinom([b1])


println()
# a = Polinom{Float64}([1,2,1])
# b = Polinom{Float64}([1,1])
 print(a); print("\t\t\t\t\t"); print(b); println()
println()
print(a+b)
println()
print(a-b)
println()
print(a*b)
println()
# inverse(b.coef[end]) |> print
# println()

# println(Polinom{Residu{Int,R}}([a.coef[end]/b.coef[end]]))
# println(size(a.coef)[1])
# println(size(b.coef)[1])
# println(get_max_pow(dim(a) - dim(b),Residu{Int,R}))
# println( a - Polinom{Residu{Int,R}}([a.coef[end]/b.coef[end]])*get_max_pow(dim(a) - dim(b),Residu{Int,R}))
print((a/b)[1]); println("\t"); print((a/b)[2])
