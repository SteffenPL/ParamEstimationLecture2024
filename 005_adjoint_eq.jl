using OrdinaryDiffEq, SciMLSensitivity

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

g(u,p,t) = (sum(u).^2) ./ 2

function dg(out, u, p, t, i)
    out .= -1.0 .+ u
end

ts = 0:0.5:10
res = adjoint_sensitivities(sol, Tsit5(),t = ts, dgdu_discrete = dg, g=g)
