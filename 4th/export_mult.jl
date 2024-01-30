include("components.jl")

using Test

const FILE = "func.jl"
const LEN = 100

function mtk_test_mult()
    rs = [Resistor(R=i; name=Symbol(:resistor, i)) for i in 1:LEN]
    cs = [Capacitor(C=i; name=Symbol(:capacitor, i)) for i in 1:LEN]
    @named source = ConstantVoltage(V=1.0)
    @named ground = Ground()
    rc_eqs = Equation[]
    for i in 1:LEN
        append!(
            rc_eqs,
            [
                connect(source.p, rs[i].p)
                connect(rs[i].n, cs[i].p)
                connect(cs[i].n, source.n, ground.g)
            ]
        )
    end
    @named _rc_model = ODESystem(rc_eqs, t)
    @named rc_model = compose(_rc_model, vcat(rs, cs, source, ground))
    sys = structural_simplify(rc_model)
    u0s = [cs[i].v => 0.0 for i in 1:LEN]
    prob = ODEProblem(sys, u0s, (0, 10.0))
    sol_mtk = solve(prob, Tsit5(), saveat=0.1)
    @test sol_mtk.retcode == ReturnCode.Success
    return nothing
end

function write_mult_func()
    @info "正在导出函数..."
    rs = [Resistor(R=i; name=Symbol(:resistor, i)) for i in 1:LEN]
    cs = [Capacitor(C=i; name=Symbol(:capacitor, i)) for i in 1:LEN]
    @named source = ConstantVoltage(V=1.0)
    @named ground = Ground()
    rc_eqs = Equation[]
    for i in 1:LEN
        append!(
            rc_eqs,
            [
                connect(source.p, rs[i].p)
                connect(rs[i].n, cs[i].p)
                connect(cs[i].n, source.n, ground.g)
            ]
        )
    end
    @named _rc_model = ODESystem(rc_eqs, t)
    @named rc_model = compose(_rc_model, vcat(rs, cs, source, ground))
    sys = structural_simplify(rc_model)
    open(FILE, "w") do io
        write(io, string(ModelingToolkit.generate_function(sys)[2]))
    end
    return nothing
end

function read_mult_func()
    @info "正在读取函数..."
    f_expr = Meta.parse(read(FILE, String))
    return eval(f_expr)
end

function de_test(f, u0s=[0.0], paras=[3.0, 2.0, 1.0])
    prob = ODEProblem(f, u0s, (0, 10.0), paras)
    sol = solve(prob, Tsit5(), saveat=0.1)
    @test sol.retcode == ReturnCode.Success
    return nothing
end

function f2mtk(f, u0s=[0.0], paras=[3.0, 2.0, 1.0])
    prob = ODEProblem(f, u0s, (0, 10.0), paras)
    return modelingtoolkitize(prob)
end

write_mult_func()
f = read_mult_func()
using BenchmarkTools
@info "正在测试mtk_test_mult..."
@btime mtk_test_mult() # 504.005 ms (5388172 allocations: 348.16 MiB)
@info "正在测试de_test..."
@btime de_test(f, zeros(LEN), vcat(1.0 * collect(1:LEN), 1.0 * collect(1:LEN), 1.0)) # 39.000 μs (217 allocations: 118.12 KiB)
@info "测试完成！"

ff = read_func()
sys2 = f2mtk(ff)

open("func2.jl", "w") do io
    write(io,string(equations(sys)[1]))
end


s = read("func2.jl", String)
Meta.parse(s) |> dump