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

    Julia (second run): 0.048250 seconds (1 allocation: 16 bytes)
    Python (naive): 10.29469856 seconds
    Python (numba): 0.25468260 seconds
    Python (numpy): 0.29321269 seconds

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

# pointwise operation 
B = A .^2 .* A ./ 2

# fusing broadcast operations
B = @. A^2 * A/2

# fusing works for any function! 
g(x) = x^2 * x/2
C = g.(A)


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

# by the way, it is better to write, otherwise A[..., ...] might allocate a temporary vector
@. A[2:3, 1:2] = 2 * A[ 3:-1:2, 1:2]

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



# the difference between variables and data 

x = [1, 2, 3]
y = x 

y[2] = 10
@show x y;

# why? 
about(x)
about(y)
# the variable name `x` refers to the pointer to the data; writing `x = y` just copies that pointer!


# Takeaway #2:    The variable name is just an assigment to some underlying data!
z = copy(x)
z[2] = 11
@show x y z;
about(z)



# However, sometimes, Julia creates temporary copies as well! 

A_same = A  # B points to the same data as A  
A_view = @view A[:, 1]  # A_view points to the first column of A 
A_col = A[:, 1]  # A_col is a copy of the first column of A!!!   

A[1,1] = 1.0
A_view[1] = 2.0
A_col[1] = 3.0
@show A


# Quiz: How much new memory do the following lines use 
A_large = rand(100, 100)
@time B = A_large;
@time C = A_large[:,:];
@time @view A_large[:, :];

# Takeaway #3:  Create `view`s to explicitly refer to subset of Vectors/Matrices if needed; 
#               otherwise, it will copy a new Vector/Matrix!


#=

    3. Functions, for/while loops and if-else(-ifelse) statements 

=#

# for-loops 
for i in 1:10 
    print(i, " ")
end

for c in "abc"
    print(c)
end

# if-statements 

something = [1, 2]
if something isa Vector 
    println("'something' is a Vector")
elseif something isa Matrix 
    println("'something' is a Matrix!")
else 
    println("'something' is something else.")
end


# functions 
function my_sum(xs)

    r = 0.0 

    for x in xs
        r += x 
    end

    return r 
end

@time sum(vec_float)
@time my_sum(vec_float)   # same runtime as built-in sum function!!! (No need for C!)


# more advanced functions 
#
# there are three types of inputs  
#   1. (required) positional arguments
#   2. optional (positional) arguments 
#   3. keyword arguments 
# which always are listed in this order; keyword arguments are separated by a ';' 

function printrange(start, stop, step = 1; skipeven = false, skip10 = false )
    for i in start:step:stop 
        if !skipeven || i % 2 != 0 
            if !skip10 || i != 10 
                println(i)
            end
        end
    end
end

# it can be called in various ways
printrange(2, 6)
printrange(2, 6; skipeven = true)
printrange(2, 6, skipeven = true)  # this is the same as the line above!

printrange(2, 6, 2)

printrange(8, 12; skip10 = true, skipeven = false)

# be careful to not confuse optional arguments and keyword arguments 
# printrange(1, 5, step = 2)  # this does not work!




# Functions can be variables! 
f = printrange 
f(1,2)

f = (x) -> x^2
f(2)


# useful return types: 
function my_min(xs, fnc; return_arg = false)
    x_min = NaN
    f_min = Inf 

    for x in xs 
        val = fnc(x) 

        if val < f_min 
            x_min = x 
            f_min = val
        end
    end

    if return_arg
        return (x_min, f_min)
    else
        return f_min 
    end
end

my_min( LinRange(-100, 100, 100000), x -> cos(x))
my_min( LinRange(-100, 100, 100000), x -> cos(x), return_arg = true)


@time my_min( LinRange(-100, 100, 100000), x -> cos(x))
# Quiz: Why does this allocate?

using BenchmarkTools
@btime my_min( LinRange(-100, 100, 100000), $(x -> cos(x)))










#=  
    4. The magic incredient of Julia 
    
        Multiple dispatch...

=#


sayhello(x) = print("I am X!")
sayhello(x::Number) = print("I am a Number!")
sayhello(x::String) = print("私は $(x) です!")

sayhello("ステフェン")
sayhello(10)





#... we will use this a lot!!!

using ForwardDiff

x = ForwardDiff.Dual(1.0, 1.0)  # x = '1 + ε'     "x.value + x.partials"
y = x^3 # y = `1 + 3 ε + 3 ε^2 + ε^3` = `1 + 3ε`

z = sin(x).partials[1] == cos(x.value)

my_sin(x) = sin(x) 
my_sin(x::ForwardDiff.Dual) = ForwardDiff.Dual(my_sin(x.value), cos(x.partials[1]))

my_sin(1.0)
my_sin(x)