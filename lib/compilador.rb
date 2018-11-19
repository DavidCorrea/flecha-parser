class Compilador
  def initialize
    @r_index = 0
    @env = {}
  end

  def call(program, compiled = '')
    program.reduce(compiled) do |result, instructions|
      if instructions[0] == 'True'
        result.concat(
          "alloc($r, 1)\n"\
          "mov_int($t, 4)\n"\
          "store($r, 0, $t)"
        )
      elsif instructions[0] == 'False'
        result.concat(
          "alloc($r, 1)\n"\
          "mov_int($t, 5)\n"\
          "store($r, 0, $t)"
        )
      elsif instructions[0] == 'Nil'
        result.concat(
          "alloc($r, 1)\n"\
          "mov_int($t, 6)\n"\
          "store($r, 0, $t)"
        )
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
      elsif instructions[0] == 'ExprApply'
        "#{call [instructions[2]], result}\n"\
        "#{call [instructions[1]], result}"
      elsif instructions[0] == 'ExprVar'
        if instructions[1] == 'unsafePrintInt'
          "load(#{@loaded}, #{@last_used}, 1)\n"\
          "print(#{@loaded})"
        else
          @last_used = fresh_register
          @loaded = fresh_register
          "mov_reg(#{@last_used}, #{fetch_from_context instructions[1]})"\
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
      end
    end
  end

  def fetch_from_context(variable)
    @env[variable] || "@G_#{variable}"
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
end