require 'spec_helper'
require_relative '../lib/flecha_lexer'
require_relative '../lib/flecha_parser'

describe 'Flecha Parser' do

  it 'cuando hay un número, se retorna "ExprNumber" junto a su valor' do
    numero = 1
    string_a_analizar = numero.to_s
    lexer = FlechaLexer.new
    tokens = lexer.lex(string_a_analizar)

    expect(FlechaParser.new.parse(tokens)).to eq(['ExprNumber', numero])
  end

  it 'cuando hay un caracter, se retorna "ExprChar" junto a su valor ASCII' do
    caracter = 'a'
    string_a_analizar = "'#{caracter}'"
    lexer = FlechaLexer.new
    tokens = lexer.lex(string_a_analizar)

    expect(FlechaParser.new.parse(tokens)).to eq(['ExprChar', caracter.ord])
  end

  it 'cuando hay un string, se retorna "ExprChar" junto a su valor ASCII' do
    caracter = 'a'
    string_a_analizar = "'#{caracter}'"
    lexer = FlechaLexer.new
    tokens = lexer.lex(string_a_analizar)

    expect(FlechaParser.new.parse(tokens)).to eq(['ExprChar', caracter.ord])
  end
end