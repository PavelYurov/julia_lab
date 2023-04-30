function comp_sort!(arr::AbstractArray, factor = 1.2473309)
    step = length(arr)
    @inbounds while step >= 1
        i = 1
        @inbounds while i + step <= length(arr)
            @inbounds if arr[i] > arr[i+step]
                @inbounds arr[i], arr[i+step] = arr[i+step],arr[i]
            end
            i+=1
        end
        step = Int64(floor(step/factor))
    end
    return arr
end


function sorted(arr::AbstractArray)
    for i in 2:length(arr)
        @inbounds if arr[i-1] > arr[i]
            return false
        end
    end
    return true
end

function bubble_sort!(arr::AbstractArray)
    while ! sorted(arr)
        @inbounds for i in 2:length(arr)
            @inbounds if arr[i-1] > arr[i]
                @inbounds arr[i-1],arr[i] = arr[i],arr[i-1]
            end
        end
    end
    return arr
end

function add_to!(arr::AbstractArray, element)
    index = 1
    @inbounds for i in length(arr):-1:1
        if arr[i] < element
            index = i+1
            break
        end
    end
    insert!(arr,index,element)
end

function ins_sort!(arr::AbstractArray)
    len = 0
    ans = similar(arr)
    @inbounds for i in 1:length(arr)
        @inbounds add_to!(ans, arr[i])
    end
    arr = ans
    return arr
end

function sh_sort!(arr::AbstractArray,step_series = (length(arr)÷2^i for i in 1:Int(floor(log2(length(arr))))))
    for step in step_series
        @inbounds for step in step_series
            @inbounds for i in firstindex(arr):lastindex(arr)-step
            j = i
            @inbounds while j >= firstindex(arr) && arr[j] > arr[j+step]
                @inbounds arr[j], arr[j+step] = arr[j+step], arr[j]
                j -= step
            end
        end
    end
    return arr
end
end

function merge_sort(arr1::AbstractArray, arr2::AbstractArray = [])
    len1 =  length(arr1)
    len2 =  length(arr2)
    if len1 > 1
        @inbounds arr1 = merge_sort(arr1[1:div(len1,2)],arr1[div(len1,2)+1:len1])
    end
    if len2 > 1
        @inbounds arr2 = merge_sort(arr2[1:div(len2,2)],arr2[div(len2,2)+1:len2])
    end
    # if len1 + len2 <= 2
    ans = []
    index1 = index2 = 1
    @inbounds for i in 1:(len1+len2)
        if index2 > len2 || (index1 <= len1 && arr1[index1] < arr2[index2]) 
            @inbounds push!(ans,arr1[index1]); index1 += 1
        else
            @inbounds push!(ans,arr2[index2]); index2 += 1
        end
    end
    return ans
end

function q_sort!(arr::AbstractArray)
    n= length(arr)
    middle = arr[div(n,2)]
    i = 1; j = n;
    @inbounds while i <= j
        @inbounds while arr[i] < middle
            i+=1
        end
        @inbounds while arr[j] > middle
            j-=1
        end
        if(i <= j)
            @inbounds arr[i],arr[j] = arr[j],arr[i]
            i+=1; j-=1
        end
    end
    if j> 1
        @inbounds @views q_sort!(arr[1:j])
    end
    if i < n
        @inbounds @views q_sort!(arr[i:end])
    end
end

function median(arr::AbstractArray)
    arr_copy = copy(arr)
    q_sort!(arr_copy)
    if mod(length(arr),2) == 1
        return arr_copy[div(length(arr),2)+1]
    else
        return (arr_copy[div(length(arr),2)+1] + arr_copy[div(length(arr),2)]) / 2
    end
end

function counting_sort!(arr::AbstractArray)
    min_val, max_val = extrema(arr)
    num_val = zeros(Int, max_val-min_val+1)
    @inbounds for val in arr
        @inbounds num_val[val-min_val+1] += 1
    end  
    k = 0
    @inbounds for (i, num) in enumerate(num_val)
        @inbounds arr[k+1:k+num] .= min_val+i-1
        k += num
    end
    return arr
end
N = 100000
A = randn(N)*1000
A = Int64.(floor.(A))
# A = [3,5,4,4,2,1,0,100,4,6,3,2,304,2,4,2,34,2,3,5,3243]
E, F, D, C, B, K, L = copy(A),copy(A),copy(A),copy(A),copy(A),copy(A),copy(A)
println("comp")
@time comp_sort!(A)
println("bubble")
@time bubble_sort!(B)
println("ins")
@time ins_sort!(C)
println("shell")
@time sh_sort!(D)
println("merge")
@time merge_sort(E)
println("quick")
@time q_sort!(F)
println("median")
@time median(K)
println("counting")
@time counting_sort!(L)
println(" ")