require 'rltk/parser'

class FlechaParser < RLTK::Parser
  left :AND, :OR, :NE, :EQ, :GE, :LE, :GT, :LT, :PLUS, :MINUS, :TIMES, :DIV, :MOD

  class Environment < Environment
    def generar_lambda(expresion, parametros)
      parametros.reverse.inject(expresion) do |result, parametro|
        ["ExprLambda", parametro, result]
      end
    end
  end

  production(:programa) do
    clause('') { [] }
    clause('programa definicion') { |programa, definicion| programa + [definicion] }
  end

  production(:definicion) do
    clause('DEF LOWERID DEFEQ expresion') do |_d, lower_id, _df, expr|
      ['Def', lower_id, expr]
    end

    clause('DEF LOWERID parametros DEFEQ expresion') do |_d, lower_id, params, _df, expr|
      ['Def', lower_id, generar_lambda(expr, params)]
    end
  end

  production(:expresion) do
    clause('expresion_externa') { |expr| expr }
    clause('expresion_externa SEMICOLON expresion') do |expr_externa, _semi, expresion|
      ["ExprLet", "_", expr_externa, expresion]
    end
  end

  production(:expresion_externa) do
    clause('expresion_if') { |expr| expr }
    clause('expresion_case') { |expr| expr }
    clause('expresion_let') { |expr| expr }
    clause('expresion_lambda') { |expr| expr }
    clause('expresion_interna') { |expr| expr }
  end

  production(:expresion_if) do
    clause('IF expresion_interna THEN expresion_interna ramas_else') do |_, expr_1, _, expr_2, ramas_else|
      ['ExprCase', expr_1, [['CaseBranch', 'True', [], expr_2], ramas_else]]
    end
  end

  production(:ramas_else) do
    clause('ELSE expresion_interna') do |_else, expr|
      ['CaseBranch', 'False', [], expr]
    end
    clause('ELIF expresion_interna THEN expresion_interna ramas_else') do |_, expr_1, _, expr_2, ramas_else|
      ['CaseBranch', 'False', [], ['ExprCase', expr_1, [['CaseBranch', 'True', [], expr_2], ramas_else]]]
    end
  end

  production(:expresion_lambda) do
    clause('LAMBDA parametros ARROW expresion_externa') do |_, parametros, _, expresion|
      generar_lambda(expresion, parametros)
    end
  end

  production(:parametros) do
    clause('') { [] }
    clause('LOWERID parametros') { |expr, params_list| [expr] + params_list }
  end

  production(:expresion_case) do
    clause('CASE expresion_interna ramas_case') do |_, expresion_interna, ramas_case|
      ['ExprCase', expresion_interna, ramas_case]
    end
  end

  production(:ramas_case) do
    clause('') { [] }
    clause('ramas_case rama_case') { |ramas, rama| ramas + [rama] }
  end

  production(:rama_case) do
    clause('PIPE UPPERID ARROW expresion_interna') do |_, constructor, _, expresion_interna|
      ['CaseBranch', constructor, [], expresion_interna]
    end
  end

  production(:expresion_interna) do
    clause('expresion_aplicacion') do |expresion_aplicacion|
      expresion_aplicacion
    end

    clause('expresion_interna operador_binario expresion_interna') do | expresion_interna_l, operador_binario, expresion_interna_r|
      ['ExprApply', ['ExprApply', operador_binario, expresion_interna_l], expresion_interna_r]
    end

    clause('operador_unario expresion_interna') do |operador_unario, expresion_interna|
      ['ExprApply', operador_unario, expresion_interna]
    end
  end

  production(:expresion_let) do
    clause('LET LOWERID DEFEQ expresion_interna IN expresion_externa') do |_, lower_id, _, expr_int, _, expr_ext|
      ["ExprLet", lower_id, expr_int, expr_ext]
    end
  end

  production(:operador_binario) do
    clause('AND')   { |_| %w'ExprVar AND' }
    clause('OR')    { |_| %w'ExprVar OR' }
    clause('EQ')    { |_| %w'ExprVar EQ' }
    clause('NE')    { |_| %w'ExprVar NE' }
    clause('GE')    { |_| %w'ExprVar GE' }
    clause('LE')    { |_| %w'ExprVar LE' }
    clause('GT')    { |_| %w'ExprVar GT' }
    clause('LT')    { |_| %w'ExprVar LT' }
    clause('PLUS')  { |_| %w'ExprVar ADD' }
    clause('MINUS') { |_| %w'ExprVar SUB' }
    clause('TIMES') { |_| %w'ExprVar MUL' }
    clause('DIV')   { |_| %w'ExprVar DIV' }
    clause('MOD')   { |_| %w'ExprVar MOD' }
  end

  production(:operador_unario) do
    clause('NOT')   { |_| %w'ExprVar NOT' }
    clause('MINUS') { |_| %w'ExprVar UMINUS' }
  end

  production(:expresion_atomica) do
    clause('LOWERID') { |lower_id|  ['ExprVar', lower_id] }
    clause('UPPERID') { |upper_id|  ['ExprConstructor', upper_id] }
    clause('NUMBER')  { |number|    ['ExprNumber', number] }
    clause('CHAR')    { |character| ['ExprChar', character] }
    clause('LPAREN expresion RPAREN') { |_, expresion, _| expresion }
    clause('STRING') do |string|
      string.split('').reverse.inject(%w(ExprConstructor Nil)) do | product, character |
        ['ExprApply', ['ExprApply', %w(ExprConstructor Cons), ['ExprChar', character.ord]], product]
      end
    end
  end

  production(:expresion_aplicacion) do
    clause('expresion_atomica') do |expresion_atomica|
      expresion_atomica
    end

    clause('expresion_aplicacion expresion_atomica') do |expresion_aplicacion, expresion_atomica|
      ['ExprApply', expresion_aplicacion, expresion_atomica]
    end
  end

  finalize
end