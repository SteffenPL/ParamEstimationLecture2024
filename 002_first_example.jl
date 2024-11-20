using OrdinaryDiffEq, Plots

# 1. Solving an ODE model with Julia 
function lotka_volterra!(du, u, p, t)
    (α, β, γ, δ) = p 
    (x, y) = u

    du[1] =  α * x - β * x * y
    du[2] = -γ * y + β * x * y 
end

# 2. Create initial conditions and parameters
u0 = [1.0, 1.0]
tspan = (0.0, 10.0)
p = [1.5, 1.0, 3.0, 1.0]

# 3. Solve and plot ODE
prob = ODEProblem(lotka_volterra!, u0, tspan, p)
sol = solve(prob, Tsit5())
plot(sol, labels = ["x" "y"], title = "Lotka Volterra")

