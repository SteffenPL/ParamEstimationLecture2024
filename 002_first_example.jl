using OrdinaryDiffEq, Plots, StaticArrays

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

prob = ODEProblem(lotka_volterra!, u0, tspan, p)
sol = solve(prob, Tsit5())
plot(sol, labels = ["x" "y"], title = "Lotka Volterra")




using DataFrames, CSV

df = CSV.read("datasets/data_1.csv", DataFrame)

plot(df.t, [df.x df.y], linealpha = 0.5, marker = ".", linestyle = :dash, labels = ["x (data)" "y (data)"])
plot!(sol, labels = ["x" "y"], title = "Lotka Volterra", c = [1 2])






# 2. Getting gradients
using DifferentiationInterface
using ForwardDiff, FiniteDiff

# f(x) = sum(abs2, x)
# x = [1.0, 2.0]
# value_and_gradient(f, AutoFiniteDiff(), x)

# 3. Getting gradients from our solution
function cost(prob, p, data)
    sol = solve(prob, Tsit5(), p = p)

    loss = 0.0 
    for (t,x,y) in eachrow(data) 
        loss += sum(abs2, sol(t) .- (x, y))
    end
    return loss
end

cost(prob, p, df)

fnc = let prob=prob, df=df 
    (p, theta) -> cost(prob, p, df)
end

# @time value_and_gradient(fnc, AutoForwardDiff(), p)
# @time value_and_gradient(fnc, AutoFiniteDiff(), p)



using Optimization

p_traj = []

function save_traj(state, loss_val)
    push!(p_traj, (loss_val = loss_val, u = copy(state.u)))
    return false
end

optf = OptimizationFunction(fnc, AutoForwardDiff())
optprob = OptimizationProblem(optf, p)
optsol = solve(optprob, Optimization.LBFGS(), callback = save_traj)



sol_opt = solve(prob, Tsit5(), p = optsol.u)

anim = @animate for i in eachindex(p_traj)

    sol_step = solve(prob, Tsit5(), p = p_traj[i].u)
    plot(df.t, [df.x df.y], linealpha = 0.5, marker = ".", linestyle = :dash, labels = ["x (data)" "y (data)"])
    plot!(sol_step, labels = ["x*" "y*"], title = "Lotka Volterra\n(Iteration = $(i), log(loss) = $(round(log10(p_traj[i].loss_val), digits=2)))", linewidth = 2, color = [1 2])    
    plot!(legend_position = :topright)
    ylims!(0, 4)

end
gif(anim, "anim_fps5.gif", fps = 5)

