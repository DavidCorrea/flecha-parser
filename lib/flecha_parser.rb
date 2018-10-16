require 'rltk/parser'

class FlechaParser < RLTK::Parser
  left  :PLUS, :MINUS
  right :TIMES, :DIV, :MOD

  production(:e) do
    clause('NUMBER') { |number| ['ExprNumber', number] }
    clause('CHAR')   { |character| ['ExprChar', character] }
    clause('STRING') { |string| ['ExprChar', string] }
    clause('UPPERID') { |id| ['ExprConstructor', id] }

    clause('NOT') { |_op| %w(ExprVar NOT) }

    clause('e PLUS e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar ADD), n], m] }
    clause('e MINUS e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar SUB), n], m]  }
    clause('e TIMES e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar MUL), n], m]  }
    clause('e DIV e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar DIV), n], m]  }
    clause('e MOD e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar MOD), n], m]  }

    clause('e OR e') { |b1, _op, b2| ['ExprApply', ['ExprApply', %w(ExprVar OR), b1], b2] }
    # clause('e AND e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar AND), n], m] }
    # clause('e NE e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar NE), n], m] }
    # clause('e EQ e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar EQ), n], m] }
    # clause('e LE e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar LE), n], m] }
    # clause('e GE e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar GE), n], m] }
    # clause('e GT e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar GT), n], m] }
    # clause('e LT e') { |n, _op, m| ['ExprApply', ['ExprApply', %w(ExprVar LT), n], m] }
  end

  finalize
end