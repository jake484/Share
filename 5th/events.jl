using ModelingToolkit, OrdinaryDiffEq
# 定义独立时间变量
@variables t

@connector function Pin(; name)
    sts = @variables v(t) = 1.0 i(t) = 1.0 [connect = Flow]
    return ODESystem(Equation[], t, sts, []; name=name)
end

function Ground(; name)
    @named g = Pin()
    eqs = [g.v ~ 0; g.i ~ 0]
    return compose(ODESystem(eqs, t, [], []; name=name), g)
end

function Resistor(; name, R=1.0)
    @named p = Pin()
    @named n = Pin()
    ps = @parameters R = R
    eqs = [
        p.v - n.v ~ p.i * R
        0 ~ p.i + n.i
    ]
    # events = [t ~ 1.5] => [R ~ 4R]
    return compose(ODESystem(eqs, t, [], ps;
            # continuous_events=events,
            name=name), p, n)
end


function Capacitor(; name, C=1.0)
    @named p = Pin()
    @named n = Pin()
    ps = @parameters C = C
    sts = @variables begin
        v(t) = 1.0
    end
    D = Differential(t)
    eqs = [
        v ~ p.v - n.v
        D(v) ~ p.i / C
        0 ~ p.i + n.i
    ]
    # events = [v ~ 1.5] => [v ~ 0.1v]
    return compose(ODESystem(eqs, t, sts, ps;
            # continuous_events=events,
            name=name), p, n)
end


function ConstantVoltage(; name, V=1.0)
    @named p = Pin()
    @named n = Pin()
    ps = @parameters V = V
    eqs = [
        V ~ p.v - n.v
        0 ~ p.i + n.i
    ]
    # events = [
    #     [t ~ 3.0] => [V ~ 2V]
    #     [t ~ 6.0] => [V ~ 2V]
    # ]
    return compose(ODESystem(eqs, t, [], ps;
            # continuous_events=events,
            name=name), p, n)
end

@named resistor = Resistor(R=1.0)
@named capacitor = Capacitor(C=1.0)
@named source = ConstantVoltage(V=1.0)
@named ground = Ground()

rc_eqs = [
    connect(source.p, resistor.p)
    connect(resistor.n, capacitor.p)
    connect(capacitor.n, source.n, ground.g)
]

@named _rc_model = ODESystem(rc_eqs, t)
@named rc_model = compose(_rc_model, [resistor, capacitor, source, ground])
sys = structural_simplify(rc_model)
prob = ODEProblem(sys, [capacitor.v => 0.0], (0, 10.0))

sol = solve(prob, Tsit5(), saveat=0.1)

using PlotlyJS
plot(sol.t, sol[rc_model.capacitor.v])

