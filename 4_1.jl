# using Plots
# x = []
# y = []
# for i in 0:0.1:10
#     push!(x,i)
#     push!(y,sin(i))
# end
# p = plot(y,x)

function rjga(a)
    len = size(a)
    # if len[2] - len[1] != 1
    #     print(len)
    #     return Nothing
    # end
    index = min(len[1],len[2])
    for i in index:-1:1
        #println(i)
        #println(a)
        if a[i,i] != 1 && a[i,i] != 0
            a[i,:] /= a[i,i]
        end
        #println(a)
        if i != 1
            for j in 1:i-1
                a[i-j,:] = a[i-j,:] - a[i-j,i]*a[i,:]
            end
        end
        #println(a)
        #index = index - 1
    end
    return a
end

function sjga(a)
    len = size(a)
    # if len[2] - len[1] != 1
    #     print(len)
    #     return Nothing
    # end
    index = min(len[1],len[2])
    #antiindex = max(len[1],len[2])
    for i in 1:index
        if a[i,i] != 1 && a[i,i] != 0
            a[i,:] /= a[i,i]
        end
        if i != index
            for j in 1:index - i
                a[i + j,:] = a[i+j,:] - a[i+j,i]*a[i,:]
            end
        end
    end
    return a
end

function solve_SLAE(a)
    res = rjga(sjga(a))
    len = size(a)
    for i in 1:len[1]
        if a[i,i] == 0 && a[i,end] != 0
            return Nothing
        end
    end
    return a[:,end]
end

function rangmatrix(a)
    function is_one(mat)
        for i in 1:size(mat)[1]
            if mat[i,i] != 1
                return (false,i)
            end
        end
        return true
    end
    
    len = min(size(a)[1],size(a)[1])
    srez = a[1:len,1:len]
    rjga(sjga(srez))
    while (size(srez)[1] != 1 || size(srez)[2] != 1) && !is_one(srez)[1]
        index = is_one(srez)[2]
        #a[index,:] = []
        #a[:,index] = []
        len = min(size(a)[1],size(a)[1])
        srez = a[1:len,1:len]
        rjga(sjga(srez))
    end
    return size(srez)[1]

end
a =Float64[10 1 1 1 0;
           1 3 4 7 0;
           5 5 5 5 1;
           7 2 5 3 0]

b =Float64[1 2 3;
           1 1 2]
#
#sjga(rjga(a))
#solve_SLAE(b)
#rangmatrix(a)