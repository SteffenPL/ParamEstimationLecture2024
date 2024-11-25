using OrdinaryDiffEq, Plots, StaticArrays
using DataFrames, CSV
using DifferentiationInterface, ForwardDiff, FiniteDiff
using Optimization
df = CSV.read("datasets/data_1.csv", DataFrame)


# 1. Solving an ODE model with Julia 
function lotka_volterra!(du, u, p, t)
    (α, β, γ, δ) = p 
    (x, y) = u

    du[1] =  α * x - β * x * y
    du[2] = -γ * y + β * x * y 
end

u0 = [1.0, 1.0]
tspan = (0.0, 10.0)
p = [1.5, 1.0, 3.0, 1.0]


# write your code here! 

# Part I:

# 1. Define an ODEProblem 
# 2. Solve the ODEProblem 
# 3. Plot the solutions 


# Part II: 

# 4. Define a a discrete cost functional, use the data in `df.t, df.x, df.y`
# 5. Evaluate the cost functional for some parameters. 
# 6. Compute the gradient of the cost functional

# Part III: 

# 7. Create an OptimisationProblem and solve it, try the solver Optimization.LBFGS()
# 8. Animate the solution process with the function below. For this, push! the evaluated values during the runtime into a global vector to store them.


# some helper code for creating the animation:
# 
#  - p_values is a Vector of NamedTuples with fields :u and :loss_val   (e.g. p_values[i] = (u = <parameters>, loss_val = <loss value>))
#  - odeprob is the ODE problem 
#  - df is the dataframe 
function create_animation(p_values, odeprob, df)
    anim = @animate for i in eachindex(p_values)

        sol_step = solve(odeprob, Tsit5(), p = ForwardDiff.value.(p_values[i].u))
        plot(df.t, [df.x df.y], linealpha = 0.5, marker = :circle, linestyle = :dash, labels = ["x (data)" "y (data)"])
        plot!(sol_step, labels = ["x*" "y*"], title = "Lotka Volterra\n(Iteration = $(i), log(loss) = $(round(log10(ForwardDiff.value(p_values[i].loss_val)), digits=2)))", linewidth = 2, color = [1 2])    
        plot!(legend_position = :topright)
        ylims!(0, 4)

    end
    gif(anim, "anim.gif", fps = 5)
end



