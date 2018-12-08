class Compilador
  def initialize
    @r_index = 0
    @routine_index = 0
    @env = {}
    @fun_env = {}
  end

  def call(program, compiled = '')
    program.reduce(compiled) do |result, instructions|
      if instructions[0] == 'True'
        compile_isolated_constructor_with code: '4'
      elsif instructions[0] == 'False'
        compile_isolated_constructor_with code: '5'
      elsif instructions[0] == 'Nil'
        compile_isolated_constructor_with code: '6'
      elsif instructions[0] == 'ExprChar'
        @last_used = fresh_register
        "alloc(#{@last_used}, 2)\n"\
        "mov_int($t, 2)\n"\
        "store(#{@last_used}, 0, $t)\n"\
        "mov_int($t, #{instructions[1].ord})\n"\
        "store(#{@last_used}, 1, $t)"
      elsif instructions[0] == 'ExprNumber'
        @last_used = fresh_register
        "alloc(#{@last_used}, 2)\n"\
        "mov_int($t, 1)\n"\
        "store(#{@last_used}, 0, $t)\n"\
        "mov_int($t, #{instructions[1]})\n"\
        "store(#{@last_used}, 1, $t)"
      elsif instructions[0] == 'ExprVar'
        if instructions[1] == 'unsafePrintInt'
          loaded = fresh_register
          "load(#{loaded}, #{@last_used}, 1)\n"\
          "print(#{loaded})"
        elsif @fun_env.has_key?(instructions[1])
          @last_used = fresh_register
          "load(#{@last_used}, $fun, #{@fun_env[instructions[1]]})"
        else
          @last_used = fresh_register
          "mov_reg(#{@last_used}, #{fetch_from_context instructions[1]})"
        end
      elsif instructions[0] == 'ExprLet'
        @let = true
        to_temp = "#{call [instructions[2]], result}"
        @env[instructions[1]] = '$temp'
        @let = false
        "#{to_temp}\n#{call [instructions[3]], result}"
      elsif instructions[0] == 'Def'
        result.concat(
          "#{call [instructions[2]], result}\n"\
          "mov_reg(@G_#{instructions[1]}, #{@last_used})"
        )
      elsif instructions[0] == 'ExprLambda'
        routine_name = fresh_routine_name
        routine_register = fresh_register
        @fun_env[@arg] = @fun_env.size + 2 if @arg
        @arg = instructions[1]

        "alloc(#{routine_register}, 3)\n"\
        "mov_int($t, 3)\n"\
        "store(#{routine_register}, 0, $t)\n"\
        "#{routine_name}:\n"\
        "mov_reg($fun, @fun)\n"\
        "mov_reg($arg, @arg)\n"\
        "#{call [instructions[2]], result}\n"\
        "mov_reg($res, #{@last_used})\n"\
        "mov_reg(@res, $res)\n"\
        "return()\n"\
        "mov_label($t, #{routine_name})\n"\
        "store(#{routine_register}, 1, $t)\n"\
        "store(#{routine_register}, 2, $arg)"
      elsif instructions[0] == 'ExprApply'
        if instructions[1][1] == 'unsafePrintInt'
          "#{call [instructions[2]], result}\n"\
          "#{call [instructions[1]], result}"
        else
          clausura = instructions[1]
          parametro = instructions[2]

          a = call([clausura], result)
          registro_clausura = @last_used
          b = call([parametro], a)
          registro_parametro = @last_used

          if true
            registro_rutina = fresh_register

            "#{a}\n"\
            "#{b}\n"\
            "load(#{registro_rutina}, #{registro_clausura}, 1)\n"\
            "mov_reg(@fun, #{registro_clausura})\n"\
            "mov_reg(@arg, #{registro_parametro})\n"\
            "icall(#{registro_rutina})\n"\
            "mov_reg(#{fresh_register}, @res)"
          else
            alloc($r, 3)
            mov_int($t, 7)
            store($r, 0, $t)
            store($r, 1, $r1)
            store($r, 2, $r2)
          end
        end
      end
    end
  end

  def compile_isolated_constructor_with(code:)
    @last_used = fresh_register
    "alloc(#{@last_used}, 1)\n"\
    "mov_int($t, #{code})\n"\
    "store(#{@last_used}, 0, $t)"
  end

  def fetch_from_context(variable)
    if @arg == variable
      '$arg'
    else
      @env[variable] || "@G_#{variable}"
    end
  end

  def fresh_register
    if @let
      '$temp'
    else
      fresh = @r_index
      @r_index += 1

      "$r#{fresh}"
    end
  end

  def fresh_routine_name
    @routine_index += 1

    "rtn_#{@routine_index}"
  end
end