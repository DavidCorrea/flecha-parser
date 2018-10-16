require 'spec_helper'
require_relative '../lib/flecha_lexer'
require_relative '../lib/flecha_parser'

describe FlechaParser do
  let(:parser) { FlechaParser.new }
  let(:lexer) { FlechaLexer.new }

  it 'cuando hay un número, se retorna "ExprNumber" junto a su valor' do
    numero = 1
    string_a_analizar = numero.to_s
    tokens = lexer.lex(string_a_analizar)

    expect(parser.parse(tokens)).to eq(['ExprNumber', numero])
  end

  it 'cuando hay un caracter, se retorna "ExprChar" junto a su valor ASCII' do
    caracter = 'a'
    string_a_analizar = "'#{caracter}'"
    tokens = lexer.lex(string_a_analizar)

    expect(parser.parse(tokens)).to eq(['ExprChar', caracter.ord])
  end

  it 'cuando hay un string, se retorna "ExprChar" junto a su valor ASCII' do
    caracter = 'a'
    string_a_analizar = "'#{caracter}'"
    tokens = lexer.lex(string_a_analizar)

    expect(parser.parse(tokens)).to eq(['ExprChar', caracter.ord])
  end

  shared_examples 'parsea el operador' do |string, expected_result|
    it do
      tokens = lexer.lex(string)

      expect(parser.parse(tokens)).to eq(expected_result)
    end
  end

  it_behaves_like 'parsea el operador', '2 + 1', ["ExprApply", ["ExprApply", %w(ExprVar ADD), ["ExprNumber", 2]], ["ExprNumber", 1]]
  it_behaves_like 'parsea el operador', '3 - 1', ["ExprApply", ["ExprApply", %w(ExprVar SUB), ["ExprNumber", 3]], ["ExprNumber", 1]]
  it_behaves_like 'parsea el operador', '4 * 12', ["ExprApply", ["ExprApply", %w(ExprVar MUL), ["ExprNumber", 4]], ["ExprNumber", 12]]
  it_behaves_like 'parsea el operador', '12 / 4', ["ExprApply", ["ExprApply", %w(ExprVar DIV), ["ExprNumber", 12]], ["ExprNumber", 4]]
  it_behaves_like 'parsea el operador', '20 % 5', ["ExprApply", ["ExprApply", %w(ExprVar MOD), ["ExprNumber", 20]], ["ExprNumber", 5]]

  it_behaves_like 'parsea el operador', 'True || False', ["ExprApply", ["ExprApply", %w(ExprVar OR), ["ExprConstructor", 'True']], ["ExprConstructor", 'False']]
  # it_behaves_like 'parsea el operador', '&&', 'AND'
  # it_behaves_like 'parsea el operador', '!', 'NOT'
  #
  # it_behaves_like 'parsea el operador', '!=', 'NE'
  # it_behaves_like 'parsea el operador', '==', 'EQ'
  # it_behaves_like 'parsea el operador', '>=', 'GE'
  # it_behaves_like 'parsea el operador', '<=', 'LE'
  # it_behaves_like 'parsea el operador', '<', 'LT'
  # it_behaves_like 'parsea el operador', '>', 'GT'
end