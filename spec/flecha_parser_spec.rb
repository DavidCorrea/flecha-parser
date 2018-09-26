require 'spec_helper'
require_relative '../lib/flecha_lexer'

describe 'Flecha Reader' do
  shared_examples 'solo devuelve el token End of String (EOS)' do
    it 'solo devuelve el token de End of String (EOS)' do
      tokens = FlechaLexer.new.tokenize(string)

      expect(tokens.size).to eq(1)
      expect(tokens.first.type).to be(:EOS)
    end
  end

  context 'cuando hay espacios vacios' do
    let(:string) { ' ' }

    include_examples 'solo devuelve el token End of String (EOS)'
  end

  context 'cuando hay tabs' do
    let(:string) { "\t" }

    include_examples 'solo devuelve el token End of String (EOS)'
  end

  context 'cuando hay saltos de linea' do
    let(:string) { "\n" }

    include_examples 'solo devuelve el token End of String (EOS)'
  end

  context 'cuando hay saltos de linea' do
    let(:string) { "\r" }

    include_examples 'solo devuelve el token End of String (EOS)'
  end

  context 'cuando hay comentarios' do
    let(:string) { "-- Esto es un comentario \n" }

    include_examples 'solo devuelve el token End of String (EOS)'
  end
end