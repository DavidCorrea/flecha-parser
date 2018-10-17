require 'rltk/parser'

class FlechaParser < RLTK::Parser
  left  :PLUS, :MINUS, :NE
  right :TIMES, :DIV, :MOD

  production(:e) do
    clause('NUMBER') { |number| ['ExprNumber', number] }
    clause('CHAR')   { |character| ['ExprChar', character] }
    clause('NUMCHAR')   { |number| ['ExprChar', number] }
    clause('STRING') do |string|
      operations = string.split("").reverse.map do |char|
        ["ExprApply",
          %w(ExprConstructor Cons),
          ['ExprChar', char]
        ]
      end

      result_base = %w(ExprConstructor Nil)
      operations.each do |operation|
        result_base = ["ExprApply", operation, result_base]
      end

      result_base
    end
    clause('UPPERID') { |id| ['ExprConstructor', id] }
    clause('LOWERID') { |id| ['ExprVar', id] }

    clause('NOT') { |_op| %w(ExprVar NOT) }

    clause('e PLUS e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar ADD), n], m] }
    clause('e MINUS e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar SUB), n], m]  }
    clause('e TIMES e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar MUL), n], m]  }
    clause('e DIV e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar DIV), n], m]  }
    clause('e MOD e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar MOD), n], m]  }

    clause('e OR e') { |b1, _op, b2| ['ExprApply', ['ExprApply', %w(ExprVar OR), b1], b2] }
    clause('e AND e') { |b1, _op, b2| ['ExprApply', ['ExprApply', %w(ExprVar AND), b1], b2] }
    clause('NOT e') { |_op, b| ['ExprApply', %w(ExprVar NOT), b] }

    clause('e NE e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar NE), n], m] }
    clause('e EQ e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar EQ), n], m] }

    clause('e LE e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar LE), n], m] }
    clause('e GE e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar GE), n], m] }
    clause('e GT e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar GT), n], m] }
    clause('e LT e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar LT), n], m] }

    clause('LPAREN e RPAREN') { |_lparen, e, _rparen| e }

    clause('DEF e DEFEQ e') { |_def, name, _defeq, expr| ['Def', name[1], expr] }
  end

  finalize
end