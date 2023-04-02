function l(x)

    return cos(x) - x

end
mutable struct Node
    index::Int
    child::Array
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



function quick_pow(a,n::Integer)

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

function quick_pow(a,n::Integer,z::Int)

    k=n; p=a; t=1

    #ИНВАРИАНТ: p^k * t == a^n

    while k>0

        if iseven(k)

            k /= 2 

            p = mod(p*p,z)

        else

        k -= 1

        t = mod(t*p, z)

        end

    end

    return mod(t,z)

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



function fibanaci(n::Int)

    f1 = (1 + sqrt(5))/2

    f2 = (1 - sqrt(5))/2

    return((quick_pow(f1,n) - quick_pow(f2,n))/sqrt(5))

end



#=

module Newton1 #из лекции

function newton1(r::Function, x; epsilon = 1e-8, num_max = 100)

    dx = r(x); x += dx; k=1

    while abs(dx) > epsilon && k < num_max

        dx = r(x); x += dx; k += 1

    end

    abs(dx) > epsilon

    return x

end

Base.abs(x::AbstractVector) = maximum(abs.(x))

end
=#



#=module Newton

function newton(f::Function, x; epsilon = 1e-8, num_max = 10)

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

end=#



# f9(x) = x^3 -3*x^2 + 3*x^3 + 5

# Newton.newton(f9,1) |> println

function is_prime1(p::Integer)
    if (p < 2)
        return false;
    elseif p == 2
        return true
    else
        return quick_pow(2,p-1,p) == 1
    end
end

function is_prime2(p::Int)
    if (p < 2)
        return false
    elseif p == 2
        return true
    else
        for i in 2:Int(round(sqrt(p)+1.0))
            if p%i == 0
                return Bool(p==i)
            end
        end
        return true
    end
end

function eratos(n::Int)
    arr = ones(Bool,n)
    arr[1] = false
    for i in 2:n
        if arr[i] == true
            for j in (i^2):i:n
                arr[j] = false
            end
        end
    end
    return findall(arr)
end

function factor(n::T) where T <: Integer
    arr = eratos(Int(ceil(n/2)))
    arr1 = T[]; arr2 = T[]
    for i in arr[1:end]
        if(mod(n,i) == 0)
            push!(arr1,i)
            m = n
            o = 0
            while(m%i==0)
                o+=1
                m /=i
            end
            push!(arr2,o)
        end
    end
    # print(arr1)
    # println()
    # print(arr2)
    return (arr1,arr2)
end

function SSD(arr::Array)
    len = length(arr)
    Σ = 0; Σ_2 = 0;
    for i in arr
        Σ += i
        Σ_2 += i*i;
    end
    Σ = Σ/len
    return Σ_2 / len - Σ*Σ
end

function mean(arr::Array)
    res = 0
    for i in arr
        res += i
    end
    return res / length(arr)
end

function SSD_2(arr::Array)
    res = 0
    for i in arr
        res += (mean(arr) - i) ^ 2 / length(arr)
    end
    return res
end

function convert_graph1(a::Node)
    s =  "[" * string(a.index)
    for i in a.child[1:end]
       s = s *convert_graph1(i) 
    end
    s = s *"]"
    return s
end
function convert_graph2(a::Node)
    s = "["
    for i in a.child[1:end]
       s = s * convert_graph2(i)
    end
    s = s * string(a.index) * "]"
    return s
end

function unconvert_graph2(s::String)
    index = 2
    function unconvert_graph()
    arr = Node[]
    while (true)
        if s[index] == '['
            index+=1
            push!(arr,unconvert_graph())
            #index+=1
        elseif s[index] == ']'
            index+=1
            #break
        else
            str = s[index]
            index+=1
            while(s[index] != ']')
                str *= s[index]
                index+=1
            end
            return Node(parse(Int,str),arr)
        end
    end  
end
return unconvert_graph()
end

function unconvert_graph1(s::String)
    index = 2
    function unconvert_graph()
        arr = Node[]
        cucumber = 0
        while (true)
        if s[index] == '['
            index+=1
            push!(arr,unconvert_graph())
            #index+=1
        elseif s[index] == ']'
            index+=1
            return Node(cucumber,arr)
            #break
        else
            str = s[index]
            index+=1
            while(index <= length(s) && (s[index] != '[' && s[index] != ']'))
                str *= s[index]
                index+=1
            end
            cucumber += parse(Int,str)
        end
        end  
    end
    return unconvert_graph()
end

function max_path(a::Node)
    leng = 0
    for i in a.child
        leng = max(leng, max_path(i)+1)
    end
    return leng
end

function path_amount(a::Node)
    amount = 1
    if length(a.child)!= 0
        amount -= 1
        for i in a.child
            amount += path_amount(i)
        end
    end
    return amount
end

height_graph(a::Node) = max_path(a) + 1

function find(index,a::Node)
    if(a.index == index)
        return a
    end
    for i in a.child
        b = find(index,i)
        if (b != Nothing)
            return b
        end
    end
    return Nothing
end

function leafs_amount(a::Node)
    if length(a.child) == 0
        return 1
    end
    amount = 0
    for i in a.child
        amount += leafs_amount(i)
    end
    return amount
end

function node_amount(a::Node)
    # if length(a.child) == 0
    #     return 1
    # end
    amount = 1
    for i in a.child
        amount += node_amount(i)
    end
    return amount
end

function valent(a::Node)
    amount = length(a.child)
    for i in a.child
        amount += valent(i)
    end
    return amount
end

function mean_path(a::Node)
    Σ = 0
    function body(a::Node, amount)
        for i in a.child
            body(i,amount+1)
        end
        Σ += amount
    end
    body(a,1)
    return Σ / node_amount(a)
end

# d2 = unconvert_graph2(convert_graph2(a))
# d1 = unconvert_graph1(convert_graph1(a))
# convert_graph1(d1)

d1 = Node(51,Node[])
d2 = Node(52,Node[])
d3 = Node(53,Node[])
c = Node(42,Node[d1,d2])
b2 = Node(31,Node[])
b1 = Node(21,[c])
a = Node(10,[b1,b2])
convert_graph1(a)
