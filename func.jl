function (ˍ₋out, ˍ₋arg1, ˍ₋arg2, t)
    #= C:\Users\yjy\.julia\packages\SymbolicUtils\r1pzW\src\code.jl:373 =#
    #= C:\Users\yjy\.julia\packages\SymbolicUtils\r1pzW\src\code.jl:374 =#
    #= C:\Users\yjy\.julia\packages\SymbolicUtils\r1pzW\src\code.jl:375 =#
    begin
        begin
            var"source₊v(t)" = ˍ₋arg2[3]
            var"resistor₊v(t)" = (+)((*)(-1, ˍ₋arg1[1]), var"source₊v(t)")
            var"resistor₊i(t)" = (/)(var"resistor₊v(t)", ˍ₋arg2[1])
            var"resistor₊n₊i(t)" = (*)(-1//1, var"resistor₊i(t)")
            var"resistor₊p₊i(t)" = (*)(-1//1, var"resistor₊n₊i(t)")
            var"capacitor₊p₊v(t)" = ˍ₋arg1[1]
            var"capacitor₊i(t)" = var"resistor₊i(t)"
            var"capacitor₊n₊i(t)" = (*)(-1, var"capacitor₊i(t)")
            var"capacitor₊p₊i(t)" = (*)(-1//1, var"capacitor₊n₊i(t)")
            var"capacitor₊n₊v(t)" = -0.0
            var"source₊p₊v(t)" = (+)(var"source₊v(t)", var"capacitor₊n₊v(t)")
            var"source₊i(t)" = (*)(-1//1, var"resistor₊i(t)")
            var"source₊n₊i(t)" = (*)(-1//1, var"source₊i(t)")
            var"source₊p₊i(t)" = (*)(-1//1, var"source₊n₊i(t)")
            var"ground₊g₊v(t)" = 0.0
            var"resistor₊p₊v(t)" = var"source₊p₊v(t)"
            var"resistor₊n₊v(t)" = var"capacitor₊p₊v(t)"
            var"source₊n₊v(t)" = var"capacitor₊n₊v(t)"
            var"ground₊g₊i(t)" = (+)((*)(-1, var"resistor₊i(t)"), var"capacitor₊i(t)")
            begin
                #= C:\Users\yjy\.julia\packages\Symbolics\OrNx6\src\build_function.jl:537 =#
                #= C:\Users\yjy\.julia\packages\SymbolicUtils\r1pzW\src\code.jl:422 =# @inbounds begin
                        #= C:\Users\yjy\.julia\packages\SymbolicUtils\r1pzW\src\code.jl:418 =#
                        ˍ₋out[1] = (/)(var"capacitor₊i(t)", ˍ₋arg2[2])
                        #= C:\Users\yjy\.julia\packages\SymbolicUtils\r1pzW\src\code.jl:420 =#
                        nothing
                    end
            end
        end
    end
end