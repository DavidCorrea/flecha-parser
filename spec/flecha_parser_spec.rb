require 'spec_helper'
require_relative '../lib/flecha_lexer'

describe 'Flecha Reader' do
  shared_examples 'no se genera ningún token' do
    it 'no devuelve ningún token' do
      tokens = FlechaLexer.new.tokenize(string)

      expect(tokens.size).to eq(0)
    end
  end

  shared_examples 'se genera un token' do | token |
    it 'no devuelve ningún token' do
      tokens = FlechaLexer.new.tokenize(string)

      expect(tokens.size).to eq(1)
      expect(tokens.first.type).to eq(token)
    end
  end

  context 'cuando hay espacios vacios' do
    let(:string) { ' ' }

    include_examples 'no se genera ningún token'
  end

  context 'cuando hay tabs' do
    let(:string) { "\t" }

    include_examples 'no se genera ningún token'
  end

  context 'cuando hay saltos de linea' do
    let(:string) { "\n" }

    include_examples 'no se genera ningún token'
  end

  context 'cuando hay saltos de linea' do
    let(:string) { "\r" }

    include_examples 'no se genera ningún token'
  end

  context 'cuando hay comentarios' do
    let(:string) { "-- Esto es un comentario \n" }

    include_examples 'no se genera ningún token'
  end

  context 'cuando hay un identificador que comienza en minuscula' do
    let(:string) { 'identificador' }

    include_examples 'se genera un token', :LOWERID
  end

  context 'cuando hay un identificador que comienza en mayuscula' do
    let(:string) { 'Identificador' }

    include_examples 'se genera un token', :UPPERID
  end
end