# 可通过
include("components.jl")

using Test

const FILE = "func.jl"

function mtk_test()
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
    prob = ODAEProblem(sys, [capacitor.v => 0.0], (0, 10.0))
    # prob = ODEProblem(sys, [capacitor.v => 0.0], (0, 10.0)) 3.749 ms (193433 allocations: 13.08 MiB)
    sol_mtk = solve(prob, Tsit5(), saveat=0.1)
    @test sol_mtk.retcode == ReturnCode.Success
    return nothing
end

function write_func()
    @info "正在导出函数..."
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
    open(FILE, "w") do io
        write(io, string(ModelingToolkit.generate_function(sys)[2]))
    end
    return nothing
end

function read_func()
    @info "正在导入函数..."
    f_expr = Meta.parse(read(FILE, String))
    return eval(f_expr)
end

function de_test(f, u0s=[0.0], paras=[3.0, 2.0, 1.0])
    prob = ODEProblem(f, u0s, (0, 10.0), paras)
    sol = solve(prob, Tsit5(), saveat=0.1)
    @test sol.retcode == ReturnCode.Success
    return nothing
end

write_func()
f = read_func()
using BenchmarkTools
@info "正在测试mtk_test..."
@btime mtk_test() # 122.216 ms (193433 allocations: 13.08 MiB)
@info "正在测试de_test..."
@btime de_test(f) # 14.600 μs (228 allocations: 17.19 KiB)
@info "测试完成！"

