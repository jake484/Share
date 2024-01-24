using ModelingToolkit, OrdinaryDiffEq
# 定义独立时间变量
@variables t

"""

    function Pin(; name)

引脚函数，可定义元器件的输入输出引脚。

# arguments
- `name`: 组件名字

# variables
- `v(t)`: 电压
- `i(t)`: 电流

"""
@connector function Pin(; name)
    sts = @variables v(t) = 1.0 i(t) = 1.0 [connect = Flow]
    return ODESystem(Equation[], t, sts, []; name=name)
end

"""

    function Ground(; name)

接地元器件，是元器件的地端口。

# arguments
- `name`: 组件名字

# connectors
- `g`: 地端口

"""
function Ground(; name)
    @named g = Pin()
    eqs = [g.v ~ 0; g.i ~ 0]
    return compose(ODESystem(eqs, t, [], []; name=name), g)
end

"""
    
    function Resistor(; name, R=1.0)

电阻元件，是电路中最基本的元件，用于限制电流。

# arguments
- `name`: 组件名字
- `R`: 电阻值

# parameters
- `R`: 电阻值

# connectors
- `p`: 正端口
- `n`: 负端口

"""
function Resistor(; name, R=1.0)
    @named p = Pin()
    @named n = Pin()
    ps = @parameters R = R
    eqs = [
        p.v - n.v ~ p.i * R
        0 ~ p.i + n.i
    ]
    return compose(ODESystem(eqs, t, [], ps; name=name), p, n)
end

"""

    function Capacitor(; name, C=1.0)

电容元件，是电路中最基本的元件，用于存储电荷。

# arguments
- `name`: 组件名字
- `C`: 电容值

# parameters
- `C`: 电容值

# connectors
- `p`: 正端口
- `n`: 负端口
"""
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
    return compose(ODESystem(eqs, t, sts, ps; name=name), p, n)
end

"""

    function ConstantVoltage(; name, V=1.0)

恒压源元件，提供恒定电压。

# arguments
- `name`: 组件名字
- `V`: 电压值

# parameters
- `V`: 电压值

# connectors
- `p`: 正端口
- `n`: 负端口

"""
function ConstantVoltage(; name, V=1.0)
    @named p = Pin()
    @named n = Pin()
    ps = @parameters V = V
    eqs = [
        V ~ p.v - n.v
        0 ~ p.i + n.i
    ]
    return compose(ODESystem(eqs, t, [], ps; name=name), p, n)
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
u0 = [capacitor.v => 0.0]
prob = ODAEProblem(sys, u0, (0, 10.0))
sol = solve(prob, Tsit5(), saveat=0.1)

# 组合元件
@named r = Resistor(R=1.0)
@named c = Capacitor(C=1.0)
con = [
    connect(r.p, c.p)
    connect(r.n, c.n)
]
@named _model = ODESystem(rc_eqs, t)
@named model = compose(_model, [resistor, capacitor, source, ground])
sys = structural_simplify(model)
# 查看电容电压变化
# sol(1.35234)