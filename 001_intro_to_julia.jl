#= 

    A quick introduction to the Julia programming language for scientific modelling.

=# 


#= 1. 

    Why Julia 
    - Julia is a high-level, high-performance, dynamic programming language.
    - Julia is designed for numerical and scientific computing.
    - Julia is open source and free to use.
    - Julia has a simple and easy-to-learn syntax.

    All programming languages are cool! And especially python/MATLAB have proven 
    to be useful! 

    However. Both suffer from the two language problem: 
    - high level code is written in python 
    - high performance code relies on C/C++ implementations (numpy, pytorch, etc)

    The aim was to make both possible in one language. -> Julia!
=# 


#=

    Demonstration of Julia's speed.

=#


function pairwise(x, fnc)

    result = 1.0
    for i in eachindex(x)
        for j in 1:i-1
            result += fnc(x[i], x[j])
        end
    end

    return result
end

x = rand(10_000)
fnc(x,y) = x^2/y

@time pairwise(x, fnc)


#= 
    On my computer:

    Julia:
    Python (naive):
    Python (numba):
    Python (numpy):

=#




#=
    2. Basic Syntax

    Basic Types, Vectors, Matrices

    https://docs.julialang.org/en/v1/manual/mathematical-operations/

=#

number = 1.0                # Float64 
integer = 2                 # Int64 
boolean = false && true     # Bool 

vec = [1.0, 2.0]            # (column) Vector
row = [1.0 -1.0]            # (row vector) Matrix (size = 1 × 2)

A = [   1.0 -1;             # Matrix (size = 3 × 2)
        2   -2; 
        4   -4]

# matrix-vector multiplication
b = A * vec

# adjoint 
c = row * mat' 

# solving linear systems 
# A x = b 
x = A \ b

# indexing
x[1]    # first element  (index-1 based)
x[2]    # second element 
x[1:2]  # slice: first to second element

A[:,1]          # first column
A[1,:]          # first row 
A[2:3, 1:2]     # lower 2 × 2 block of matrix

A[2:3, 1:2] .= 2 * A[ 3:-1:2, 1:2]      # ranges a:step:b = from a with stepsize step to b


# Vectors and be extended!
a = [1, 2, 3]
push!(a, 4)


#=

    The workings underneath: Memory layout in Julia.

=#

# Important: Vectors have an elementyype `eltype(a)`

eltype(a)
eltype(x)

# push!(a, 1.5)  # doesn't work, because eltype(a) == Int64 cannot store an Float64

using About
about(x)
about(a)

list = ["Hello", 1, 2.0, true]
about(list)
about([1,2,3,4])     
about(Any[1,2,3,4])
about("Hello")


vec_float = rand(10000)
vec_any = convert(Vector{Any}, vec_float)

@time sum(vec_float)    # 0.000010 seconds (1 allocation: 16 bytes)
@time sum(vec_any)      # 0.000136 seconds (10.00 k allocations: 156.234 KiB)
# 10x slower, just because we don't know the types in `vec_any`


# Takeaway #1:  In Julia, we have to care about the datatypes! 
#   -> good memory layout of data is one of most important factors for performance!



#=

    3. Functions, for/while loops and if-else(-ifelse) statements 

=#

for i in 1:10 
    print(i, " ")
end

for c in "abc"
    print(c)
end


function my_sum(xs)

    r = 0.0 

    for x in xs
        r += x 
    end

    return r 
end

@time sum(vec_float)
@time my_sum(vec_float)   # same runtime as built-in sum function!!! (No need for C!)

