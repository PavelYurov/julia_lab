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

#a =Residu{Int,10}(13)
#inverse(a)
