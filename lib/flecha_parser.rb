require 'rltk/parser'

class FlechaParser < RLTK::Parser
  production(:expresion_atomica) do
    clause('NUMBER') { |number| ['ExprNumber', number] }
    clause('CHAR')   { |character| ['ExprChar', character] }
    clause('STRING') { |string| ['ExprChar', character] }
  end

  finalize
end