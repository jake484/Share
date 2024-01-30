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
prob = ODEProblem(sys, [capacitor.v => 0.0], (0, 10.0))
sol = solve(prob, Tsit5(), saveat=0.1)
@test sol.retcode == ReturnCode.Success

# 生成函数语法树
a = ModelingToolkit.generate_function(sys)
# 导出
open("func.jl", "w") do io
    write(io, string(ModelingToolkit.generate_function(sys)[2]))
end

# ModelingToolkit.varmap_to_vars(
#     [
#         capacitor.v => 0.0,
#         source.p.v => 1.0,
#     ],
#     [source.p.v, capacitor.v]
# )

# modelingtoolkitize 从函数编译至MTK
# sys = modelingtoolkitize(prob)