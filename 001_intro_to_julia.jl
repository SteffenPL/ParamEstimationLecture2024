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

    Basic Types, Vectors, Matrices, Tuples and NamedTuples


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



# Vectors and be extended!
a = [1, 2, 3]
push!(a, 4)

# Important: Vectors have an elementyype `eltype(a)`

eltype(a)
eltype(x)

# push!(a, 1.5)  # doesn't work, because eltype(a) == Int64 cannot store an Float64