include("components.jl")
using Test
@named resistor = Resistor(R=3.0)
@named capacitor = Capacitor(C=2.0)
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
equations(sys) |> display
prob = ODAEProblem(sys, [capacitor.v => 0.0], (0, 10.0))
sol_mtk = solve(prob, Tsit5(), saveat=0.1)
@test sol.retcode == ReturnCode.Success
# 显示所有状态
for state in states(rc_model)
    println(state, " = ", sol[state][1:2])
end

# 求解步长设置

# 组合元件，化简
@named r = Resistor(R=1.0)
@named r2 = Resistor(R=2.0)
@named c = Capacitor(C=1.0)
con = [
    connect(r.p, c.p)
    connect(r2.p, c.n)
    connect(r.n, r2.n)
]
@named _model = ODESystem(rc_eqs, t)
@named model = compose(_model, [resistor, capacitor, source, ground])
sys = structural_simplify(model)

# 生成函数语法树
ModelingToolkit.generate_function(sys)
# 导出
open("sys.jl", "w") do io
    write(io, string(ModelingToolkit.generate_function(sys)[2]))
end


# ModelingToolkit.varmap_to_vars(
#     [
#         capacitor.v => 0.0,
#         source.p.v => 1.0,
#     ],
#     [source.p.v, capacitor.v]
# )

