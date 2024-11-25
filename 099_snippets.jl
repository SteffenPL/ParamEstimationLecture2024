# Solving an ODE 
using OrdinaryDiffEq, Plots

# Define right-hand side of ODE as a in-place function
function ode(du, u, p, t)
	du[1] = p[1] * u[1]
end

tspan = (0.0, 10.0)	# time interval
p = [-1.0]			# parameters
u0 = [1.0]			# initial value

odeprob = ODEProblem(ode, u0, tspan, p)
odesol = solve(odeprob, Tsit5())

plot(odesol, labels = ["x(t)"], title = "First-order ODE")



# Computing a finite difference 
using DifferentiationInterface, ForwardDiff, FiniteDiff

f(x) = sum(abs2, x)
x = [1.0, 2.0]
value_and_gradient(f, AutoFiniteDiff(), x)



# Computing gradients with forward differentiation 
value_and_gradient(f, AutoForwardDiff(), x)



# Solving an Optimisation problem 
using Optimization, LinearAlgebra

fnc(p, theta) = norm(p - [10, pi])
p0 = [0.0, 0.0]

optf = OptimizationFunction(fnc, AutoForwardDiff())
optprob = OptimizationProblem(optf, p0)
optsol = solve(optprob, Optimization.LBFGS())




# Creating a cost function 
using DiffEqParamEstim

ts = [0.0, 5.0, 7.0, 9.0]
xs = @. exp( -0.2 * ts )

cost_function = build_loss_objective(odeprob, Tsit5(), 
                    L2Loss(ts, xs),
                    Optimization.AutoForwardDiff(),
                    maxiters = 10000)

cost_function([-0.2])
cost_function([0.2])