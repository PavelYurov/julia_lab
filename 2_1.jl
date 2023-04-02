function l(x)
    return cos(x) - x
end


function root(f::Function, a, b, e = 1.0e-10)
    while abs(a - b) >= e
        mid = ((a + b)/2)
        if f(mid) == 0
            return mid
        end 
        if sign(f(a)) != sign(f(mid))
            b = mid
        else
            a = mid
        end
    end
    return (a,b)
end

function root(e,z_x)
    z_y = z_x - (z_x^3 - 1)/(3*z_x^2)
    while Base.abs(z_y - z_x) >= e
        z_x = z_y
        z_y = z_x - (z_x^3 - 1)/(3*z_x^2)
    end
    return (z_y,z_x)
end

function quick_pow(a,n::Int)
    k=n; p=a; t=1
    #ИНВАРИАНТ: p^k * t == a^n
    while k>0
        if iseven(k)
            k /= 2 
            p *= p
        else
        k -= 1
        t *= p 
        end
    end
    return t
end

function quick_log(x, a, ε = 1.0e-8)
    z=x; t=1; y=0
    #ИНВАРИАНТ:  x = z^t * a^y
while z < 1/a || z > a || t > ε 
    if z < 1/a
        z *= a 
        y -= t 
    elseif z > a
        z /= a 
        y += t 
    elseif t > ε
        t /= 2
        z *= z
    end
end
    return y
end

# function fibanaci(n::Int)
#     f1 = (1 + sqrt(5))/2
#     f2 = (1 - sqrt(5))/2
#     return((quick_pow(f1,n) - quick_pow(f2,n))/sqrt(5))
# end

function fibanaci(n::Int)
    a = [1 1; 1 0]
    b = [1;0]
    return (quick_pow(a,n)*b)[1]
end


module Newton1
function newton1(r::Function, x; epsilon = 1e-8, num_max = 100)
    dx = r(x); x += dx; k=1
    while abs(dx) > epsilon && k < num_max
        dx = r(x);
        x += dx; k += 1
    end
    abs(dx) > epsilon
    return x
end
Base.abs(x::AbstractVector) = maximum(abs.(x))
end

module Newton
function newton(f::Function, x; epsilon = 1e-10, num_max = 10)
    δ = 1.0e-10
    function f_(x)
        return (f(x+δ) - f(x))/δ
    end
    dx = x + f(x)/f_(x)
    k = 1
    while abs(dx - x) > epsilon && k < num_max
        x = dx
        dx = x - f(x)/f_(x)
        k +=1
    end
    return x
end
Base.abs(x::AbstractVector) = maximum(abs.(x))
Base.abs(x::AbstractMatrix) = maximum(abs.(x))
end

#x^2 + y^2 = 1
#x^3 * y = 1
f9(a) = -([2*a[1] 2a[2]; 3*a[1]^2 1]\[1,1])
Newton1.newton1(f9,[1,1]) |> println


