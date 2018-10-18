require 'spec_helper'
require_relative '../lib/flecha_lexer'
require_relative '../lib/flecha_parser'

describe FlechaParser do
  let(:parser) { FlechaParser.new }
  let(:lexer) { FlechaLexer.new }

  shared_examples 'parsea la expresión' do |string, a:|
    it do
      tokens = lexer.lex(string)

      expect(parser.parse(tokens)).to eq(a)
    end
  end

  it_behaves_like 'parsea la expresión', '1', a: ['ExprNumber', 1]
  it_behaves_like 'parsea la expresión', "'a'", a: ['ExprChar', 'a'.ord]
  it_behaves_like 'parsea la expresión', '"ho"', a: ["ExprApply", ["ExprApply", %w(ExprConstructor Cons), %w(ExprChar h)], ["ExprApply", ["ExprApply", %w(ExprConstructor Cons), %w(ExprChar o)], %w(ExprConstructor Nil)]]

  it_behaves_like 'parsea la expresión', '2 + 1', a: ["ExprApply", ["ExprApply", %w(ExprVar ADD), ["ExprNumber", 2]], ["ExprNumber", 1]]
  it_behaves_like 'parsea la expresión', '3 - 1', a: ["ExprApply", ["ExprApply", %w(ExprVar SUB), ["ExprNumber", 3]], ["ExprNumber", 1]]
  it_behaves_like 'parsea la expresión', '4 * 12', a: ["ExprApply", ["ExprApply", %w(ExprVar MUL), ["ExprNumber", 4]], ["ExprNumber", 12]]
  it_behaves_like 'parsea la expresión', '12 / 4', a: ["ExprApply", ["ExprApply", %w(ExprVar DIV), ["ExprNumber", 12]], ["ExprNumber", 4]]
  it_behaves_like 'parsea la expresión', '20 % 5', a: ["ExprApply", ["ExprApply", %w(ExprVar MOD), ["ExprNumber", 20]], ["ExprNumber", 5]]
  it_behaves_like 'parsea la expresión', '-5',     a: ["ExprApply", %w(ExprVar UMINUS), ["ExprNumber", 5]]

  it_behaves_like 'parsea la expresión', 'True || False', a: ["ExprApply", ["ExprApply", %w(ExprVar OR), ["ExprConstructor", 'True']], ["ExprConstructor", 'False']]
  it_behaves_like 'parsea la expresión', 'True && False', a: ["ExprApply", ["ExprApply", %w(ExprVar AND), ["ExprConstructor", 'True']], ["ExprConstructor", 'False']]
  it_behaves_like 'parsea la expresión', '!True', a: ["ExprApply", %w(ExprVar NOT), ["ExprConstructor", 'True']]

  it_behaves_like 'parsea la expresión', '1 != 2', a: ["ExprApply", ["ExprApply", %w(ExprVar NE), ["ExprNumber", 1]], ["ExprNumber", 2]]
  it_behaves_like 'parsea la expresión', '2 == 2', a: ["ExprApply", ["ExprApply", %w(ExprVar EQ), ["ExprNumber", 2]], ["ExprNumber", 2]]
  it_behaves_like 'parsea la expresión', '1 <= 2', a: ["ExprApply", ["ExprApply", %w(ExprVar LE), ["ExprNumber", 1]], ["ExprNumber", 2]]
  it_behaves_like 'parsea la expresión', '1 >= 2', a: ["ExprApply", ["ExprApply", %w(ExprVar GE), ["ExprNumber", 1]], ["ExprNumber", 2]]
  it_behaves_like 'parsea la expresión', '3 > 2', a: ["ExprApply", ["ExprApply", %w(ExprVar GT), ["ExprNumber", 3]], ["ExprNumber", 2]]
  it_behaves_like 'parsea la expresión', '3 < 2', a: ["ExprApply", ["ExprApply", %w(ExprVar LT), ["ExprNumber", 3]], ["ExprNumber", 2]]

  it_behaves_like 'parsea la expresión', 'case x', a: ["ExprCase", ["ExprVar", "x"], []]
end