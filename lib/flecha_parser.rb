require 'rltk/parser'

class FlechaParser < RLTK::Parser
  left  :PLUS, :MINUS, :NE
  right :TIMES, :DIV, :MOD

  production(:expresion_case) do
    clause('CASE expresion_interna ramas_case') do |_, expresion_interna, ramas_case|
      ['ExprCase', expresion_interna, ramas_case]
    end
  end

  production(:ramas_case) do
    clause('') { [] }
    clause('ramas_case rama_case') { |ramas, rama| [rama] + ramas }
  end

  production(:rama_case) do
    clause('PIPE UPPERID ARROW expresion_interna') do |_, constructor, _, expresion_interna|
      ['CaseBranch', constructor, [], expresion_interna]
    end
  end

  production(:expresion_interna) do
    clause('expresion_aplicacion') { |expresion_aplicacion| expresion_aplicacion }

    clause('expresion_interna operador_binario expresion_interna') do | expresion_interna_l, operador_binario, expresion_interna_r|
      ['ExprApply', ['ExprApply', operador_binario, expresion_interna_l], expresion_interna_r]
    end

    clause('operador_unario expresion_interna') do |operador_unario, expresion_interna|
      ['ExprApply', operador_unario, expresion_interna]
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
    # clause('LPAREN expresion RPAREN') { |_, expresion, _| expresion }
    clause('STRING') do |string|
      string.split('').reverse.inject(%w(ExprConstructor Nil)) do | product, character |
        ['ExprApply', ['ExprApply', %w(ExprConstructor Cons), ['ExprChar', character]], product]
      end
    end
  end

  production(:expresion_aplicacion) do
    clause('expresion_atomica') { |expresion_atomica| expresion_atomica }
    clause('expresion_aplicacion expresion_atomica') { |_expresion_aplicacion, expresion_atomica | ['ExprApply', expresion_atomica] }
  end

  finalize
end