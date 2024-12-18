from numba import njit 
import numpy as np 
import timeit 

def pairwise_naive(x, fnc):
    return sum(fnc(x[i],x[j]) for i in range(len(x)) for j in range(i))

@njit
def pairwise_njit(x):
    z = 0.0
    for i in range(len(x)):
        for j in range(i):
            z += x[i]**2 / x[j]
    
    return z 


def pairwise_numpy(x, fnc):
    i_index = np.arange(len(x))[:,None]
    j_index = np.arange(len(x))[None,:]
    mask = j_index < i_index
    return fnc(x[:, None], x[None, :])[mask].sum()
    
x = np.random.rand(10_000)
fnc = lambda x, y: x**2/y



start = timeit.default_timer()
pairwise_naive(x, fnc)
end = timeit.default_timer()

print(f"Runtime approximatively ~ {end - start:.8f} seconds")


start = timeit.default_timer()
pairwise_njit(x)
end = timeit.default_timer()

print(f"Runtime approximatively ~ {end - start:.8f} seconds")


start = timeit.default_timer()
pairwise_numpy(x, fnc)
end = timeit.default_timer()

print(f"Runtime approximatively ~ {end - start:.8f} seconds")
