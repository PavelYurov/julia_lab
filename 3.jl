#include("1.jl")
mutable struct Polinom
    coef::Array
end

function Base.print(a::Polinom)
    if a.coef * 0 == a.coef
        print(0)
        return
    end
    if a.coef[1]!= 0
        print(a.coef[1])
    end
    n = 1
    for i in a.coef[2:end]
        if i!= 0
            if a.coef[n+1] < 0
                print("-")
            elseif (a.coef[n+1] !=  0)
                if !(n == 1 && a.coef[1] ==  0)
                    print("+")
                end
            end
            
            if abs(i) !=  1
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

function Base. +(a::Polinom , b::Polinom )
    b_ = b.coef
    a_ = a.coef
    if size(a.coef)[1]>size(b.coef)[1]
        c = Polinom(a.coef)
        for i in size(b.coef)[1]:size(a.coef)[1]-1
            push!(b_, 0)
        end
    else
        for i in size(a.coef)[1]:size(b.coef)[1]-1
            push!(a_, 0)
        end
        c = Polinom(b.coef)
    end
    c.coef  = a_ + b_
    normalize(c)
    return c
end

function Base. -(a::Polinom , b::Polinom ) 
    c = Polinom(b.coef * -1)                             #!!!!
    return a + c;
end

function normalize(a::Polinom )
    while size(a.coef)[1] > 1 && a.coef[end] ==  0 
        pop!(a.coef)
    end
end

function dim(a::Polinom )
    normalize(a)
    return size(a.coef)[1]
end

function Base. *(a::Polinom , b::Polinom )
    normalize(a);normalize(b)
    arr = []
    for i in 1:dim(a)+dim(b)
        push!(arr, 0)
    end
    n = 1
    for i in 1:dim(a)
        for j in 1:dim(b)
            arr[i+j-1] += a.coef[i]*b.coef[j]
        end
    end
    return Polinom(arr)
end
function Base. *(value::T, a::Polinom ) where T
    c = Polinom(value * a.coef)
    return c
end

function get_max_pow(value::Int)
    arr = []
    for i in 1:value+1
        push!(arr, 0)
    end
    arr[end] =   1
    return Polinom(arr)
end


function Base. /(a::Polinom , b::Polinom )
    if b == Polinom([0])
        print("деление на 0")
        return  0
    end
    ost = a
    chel = Polinom([0])
    #n = 0
    while dim(ost) >= dim(b)
        chel = chel + ((ost.coef[end]/b.coef[end])*get_max_pow(dim(ost) - dim(b)))
        del = ost.coef[end]/b.coef[end]*get_max_pow(dim(ost) - dim(b))*b
        #println(ost, "\t", del, "\t",get_max_pow(dim(ost) - dim(b)), "\t",dim(ost) - dim(b))
        ost = ost - del
        # if n == 10
        #     return (chel,ost)
        # end
        # n+=1
        normalize(ost)
    end
    return (chel,ost)
end

a = Polinom([1,2,1])
b = Polinom([1,1])
print((a/b)[1]); print("\t"); print((a/b)[2])