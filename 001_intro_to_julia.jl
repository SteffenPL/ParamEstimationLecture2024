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

