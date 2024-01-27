
using ModelingToolkit, OrdinaryDiffEq
# 定义独立时间变量
@variables t

@connector Pin begin
    v(t)
    i(t), [connect = Flow]
end

@mtkmodel Ground begin
    @components begin
        g = Pin()
    end
    @equations begin
        g.v ~ 0
    end
end

@mtkmodel OnePort begin
    @components begin
        p = Pin()
        n = Pin()
    end
    @variables begin
        v(t) = 0.0
        i(t) = 0.0
    end
    @equations begin
        v ~ p.v - n.v
        0 ~ p.i + n.i
        i ~ p.i
    end
end

@mtkmodel Resistor begin
    @extend OnePort()
    @parameters begin
        R = 1.0 # Sets the default resistance
    end
    @equations begin
        v ~ i * R
    end
end

D = Differential(t)

@mtkmodel Capacitor begin
    @extend OnePort()
    @parameters begin
        C = 1.0
    end
    @equations begin
        D(v) ~ i / C
    end
end

function change(t, V)
    return ceil(t / 4) * V
end

@register_symbolic change(t, R)

@mtkmodel ConstantVoltage begin
    @extend OnePort()
    @parameters begin
        V = 1.0
    end
    @equations begin
        V ~ v
    end
end

@mtkmodel ConstantVoltageChange begin
    @extend OnePort()
    @parameters begin
        V = 1.0
    end
    @equations begin
        change(t, V) ~ v
    end
end

@mtkmodel RCModel begin
    @components begin
        resistor = Resistor(R=1.0)
        capacitor = Capacitor(C=1.0)
        source = ConstantVoltageChange(V=1.0)
        ground = Ground()
    end
    @equations begin
        connect(source.p, resistor.p)
        connect(resistor.n, capacitor.p)
        connect(capacitor.n, source.n)
        connect(capacitor.n, ground.g)
    end
end

@mtkbuild rc_model = RCModel()

u0 = [
    rc_model.capacitor.v => 0.0,
]
prob = ODEProblem(rc_model, [], (0, 10.0))
sol = solve(prob, Rodas4(), saveat=0.1)

using PlotlyJS
plot(sol.t,sol[rc_model.capacitor.v])
