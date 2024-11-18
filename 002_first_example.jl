using DifferentialEquations, Plots

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

# 2. Getting gradients
using DifferentiationInterface
using ForwardDiff, FiniteDiff

f(x) = sum(abs2, x)
x = [1.0, 2.0]
value_and_gradient(f, AutoFiniteDiff(), x)

# 3. Getting gradients from our solution
function cost(prob, p, data)
    sol =solve(prob, Tsit5(), p = p)

    loss = 0.0 
    for (t,x) in data 
        loss += sum(abs2, sol(t) - x)
    end
    return loss
end

data = [(2.0, [5.0, 2.0]), (6.0, [4.0, 4.0])]
cost(prob, p, data)

fnc = let prob=prob, data=data 
    (p, theta) -> cost(prob, p, data)
end

@time value_and_gradient(fnc, AutoForwardDiff(), p)
@time value_and_gradient(fnc, AutoFiniteDiff(), p)



using Optimization

optf = OptimizationFunction(fnc, SecondOrder(AutoForwardDiff(),AutoForwardDiff()))
optprob = OptimizationProblem(optf, p)
optsol = solve(optprob, Optimization.Sophia())



sol_opt = solve(prob, Tsit5(), p = optsol.u)

begin
    plot(sol_opt, labels = ["x*" "y*"], color = [1 2])
    scatter!(getindex.(data, 1), getindex.(data, 2), color = [1 2])
    plot!(sol, labels = ["x" "y"], linestyle = :dash, color = [1 2])
end