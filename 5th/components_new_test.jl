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
@connector Pin begin
    v(t)
    i(t), [connect = Flow]
end

"""

    function Ground(; name)

接地元器件，是元器件的地端口。

# arguments
- `name`: 组件名字

# connectors
- `g`: 地端口

"""
@mtkmodel Ground begin
    @components begin
        g = Pin()
    end
    @equations begin
        g.v ~ 0
    end
end

"""

    function OnePort(; name)

单端口元器件，是元器件的单端口。

# arguments
- `name`: 组件名字

# connectors
- `p`: 正端口
- `n`: 负端口

"""
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
@mtkmodel Capacitor begin
    @extend OnePort()
    @parameters begin
        C = 1.0
    end
    @equations begin
        D(v) ~ i / C
    end
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
@mtkmodel ConstantVoltage begin
    @extend OnePort()
    @parameters begin
        V = 1.0
    end
    @equations begin
        V ~ v
    end
end

@mtkmodel RCModel begin
    @components begin
        resistor = Resistor(R=1.0)
        capacitor = Capacitor(C=1.0)
        source = ConstantVoltage(V=1.0)
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

# 导出
# open("func.jl", "w") do io
#     write(io, string(ModelingToolkit.generate_function(rc_model)[2]))
# end

u0 = [
    rc_model.capacitor.v => 0.0,
]
prob = ODEProblem(rc_model, [], (0, 10.0))
sol = solve(prob, Tsit5(), saveat=0.1)


# mult rc
const LEN = 100

rs = [Expr(:(=), Symbol(:resistor, i), :(Resistor(R=$i))) for i in 1:LEN]
cs = [Expr(:(=), Symbol(:capacitor, i), :(Capacitor(C=$i))) for i in 1:LEN]
comps = vcat(rs, cs, Expr(:(=), :source, :(ConstantVoltage(V=1.0))),
    Expr(:(=), :ground, :(Ground()))
)
eqs = reduce(vcat, [
    # connect(source.p, resistor.p)
    Expr(:call, :connect,
        Expr(:., :source, QuoteNode(:p)),
        Expr(:., Symbol(:resistor, i), QuoteNode(:p)))
    # connect(resistor.n, capacitor.p)
    Expr(:call, :connect,
        Expr(:., Symbol(:resistor, i), QuoteNode(:n)),
        Expr(:., Symbol(:capacitor, i), QuoteNode(:p)))
    # connect(capacitor.n, source.n, ground.g)
    Expr(:call, :connect,
        Expr(:., Symbol(:capacitor, i), QuoteNode(:n)),
        Expr(:., :source, QuoteNode(:n)),
        Expr(:., :ground, QuoteNode(:g)))
] for i in 1:LEN)

:(@mtkmodel MultRCModel begin
    @components begin
        $(comps...)
    end
    @equations begin
        $(eqs...)
    end
end) |> eval

@mtkbuild mult_rc_model = MultRCModel()

prob = ODEProblem(mult_rc_model, [], (0, 10.0))
sol = solve(prob, Tsit5(), saveat=0.1)
using Test
@test sol.retcode == ReturnCode.Success