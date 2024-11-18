using DifferentialEquations, Plots
using LinearAlgebra, StaticArrays

datat = [4.0,15,30,45]

datau = [
    2027	3526	3648	1544;
    75.11217183	315.7788309	223.6199092	295.9978857;
    452.01432	1238.92259	407.3076924	409.7145872;
    28.16706442	42.01895733	62.29411763	66.89217759;
    159	438	1651	1585;
    48	61	1379	1695
]

datau_rel = [
    72.67073039	62.72101354	49.48976084	27.58815561;
    2.69287439	5.61712091	3.033688549	5.288883246;
    16.20533339	22.0381397	5.525647008	7.320770588;
    1.009827895	0.7474394758	0.8450989538	1.195227853;
    5.700368097	7.791209283	22.39791534	28.32074265;
    1.72086584	1.085077092	18.70788931	30.28622005
]

data = (;datat, datau, datau_rel)

function ode_sa!(u, p, t)

    (I, R, F, Ft, D, T, Tt, B) = u

    (;
        G_I, G_R, G_F, G_Ft, G_D, G_T, G_Tt, G_B,
        D_I, D_R, D_F, D_Ft, D_D, D_T, D_Tt, D_B,
        TNFalpha, TGFB2, IFNgamma, CXCL9, BAFF, IL21,
        R2F, R2Ft, F2Ft, Ft2D, T2Tt, Tt2T, GC_rate
    ) = p

    dI  = G_I  - D_I * I   + TNFalpha * T
    dR  = G_R  - D_R * R   - TGFB2 * I * R2F * R - IFNgamma * Tt * R2Ft * R
    dF  = G_F  - D_F * F   - F2Ft * F + TGFB2 * I * R2F * R
    dFt = G_Ft - D_Ft * Ft - Ft2D * Ft + F2Ft * F + IFNgamma * Tt * R2Ft * R
    dD  = G_D  - D_D * D   + Ft2D * Ft
    dT  = G_T  - D_T * T   - T2Tt * T + Tt2T * Tt + CXCL9 * Ft
    dTt = G_Tt - D_Tt * Tt - Tt2T * Tt + T2Tt * T
    dB  = G_B  - D_B * B   + (GC_rate * Ft + BAFF * D + IL21 * Tt) * B

    return SA[dI, dR, dF, dFt, dD, dT, dTt, dB]
end


tspan = (0.0, 45.0)

data2u(data) = SA[data[1:4]..., 0.0, data[5]/2, data[5]/2, data[6]]
u2data(u) = SA[u[1:4]..., u[6] + u[7], u[8]]
u2data_rel(u) = normalize(u2data(u))

u0 = data2u(datau_rel[:,1])

p = (
    G_I = 0.01, G_R = 0.18, G_F = 0.01, G_Ft = 0.01, G_D = 0.01, G_T = 0.01, G_Tt = 0.01, G_B = 0.01,
    D_I = 0.05, D_R = 0.007, D_F = 0.05, D_Ft = 0.05, D_D = 0.05, D_T = 0.025, D_Tt = 0.025, D_B = 0.05,
    TNFalpha = 0.02, TGFB2 = 2e-3, IFNgamma = 1e-2, CXCL9 = 0.2, BAFF = 0.13, IL21 = 4e-3,
    R2F = 1.0, R2Ft = 1.0, F2Ft = 0.0015, Ft2D = 0.0015, T2Tt = 0.83, Tt2T = 0.0074, GC_rate = 0.03
)

odeprob = ODEProblem(ode_sa!, u0, tspan, p)
odesol = solve(odeprob, Tsit5())

labels = ["I" "R" "F" "Ft" "D" "T" "Tt" "B"]
plot(odesol; labels, yscale = :log10, ylims = (1e-1, 1e2))


function loss(prob, p, data)
    (ts, us, us_rel) = data 

    sol = solve(odeprob, Tsit5(), p = p)

    # fit percentages 
    y = 0.0 
    for k in eachindex(ts)
        t = ts[k]
        datak_rel = us_rel[k]

        uk = sol(t)
        uk_rel = u2data_rel(uk)
        y += sum(abs2, uk_rel .- datak_rel)
    end
    return y
end

loss(prob, p, data)

optp_names = (:BAFF, :CXCL9)
opt2ode(opt_p, optp_names) = (;p..., NamedTuple{optp_names}(opt_p)...)

opt_fnc = let odeprob=odeprob, data=data, p=p, optp_names=optp_names
    (optp, theta) -> loss(odeprob, opt2ode(optp, optp_names), data)
end

optp = [p.BAFF, p.CXCL9]
optf = OptimizationFunction(opt_fnc, AutoForwardDiff())
optprob = OptimizationProblem(optf, optp)

optsol = solve(optprob, Optimization.LBFGS())

optodesol = solve(odeprob, Tsit5(), p = opt2ode(optsol.u))

plot(optodesol; labels, yscale = :log10, ylims = (1e-1, 1e2))