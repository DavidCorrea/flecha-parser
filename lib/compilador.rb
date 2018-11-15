class Compilador
  def call(program, compiled = '')
    program.reduce(compiled) do |result, instruction|
      if instruction[0] == 'True'
        result.concat(
          "alloc($r, 1)\n"\
          "mov_int($t, 4)\n"\
          "store($r, 0, $t)"
        )
      elsif instruction[0] == 'False'
        result.concat(
          "alloc($r, 1)\n"\
          "mov_int($t, 5)\n"\
          "store($r, 0, $t)"
        )
      elsif instruction[0] == 'Nil'
        result.concat(
          "alloc($r, 1)\n"\
          "mov_int($t, 6)\n"\
          "store($r, 0, $t)"
        )
      elsif instruction[0] == 'ExprChar'
        "alloc($r0, 2)\n"\
        "mov_int($t, 2)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, #{instruction[1].ord})\n"\
        "store($r0, 1, $t)"
      elsif instruction[0] == 'ExprNumber'
        "alloc($r0, 2)\n"\
        "mov_int($t, 1)\n"\
        "store($r0, 0, $t)\n"\
        "mov_int($t, #{instruction[1]})\n"\
        "store($r0, 1, $t)"
      elsif instruction[0] == 'Def'
        result.concat(
          "#{call [instruction[2]], result}\n"\
          "mov_reg(@G_#{instruction[1]}, $r0)"
        ) # Acá debería ser sólo instruction[2]
      end
    end
  end
end