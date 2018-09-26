require 'spec_helper'
require_relative '../lib/flecha_lexer'

describe 'Flecha Reader' do
  shared_examples 'no se genera ningún token' do
    it 'no se genera ningún token' do
      tokens = FlechaLexer.new.tokenize(string)

      expect(tokens.size).to eq(0)
    end
  end

  shared_examples 'se genera un token' do | token |
    it 'se genera un token' do
      tokens = FlechaLexer.new.tokenize(string)

      expect(tokens.size).to eq(1)
      expect(tokens.first.type).to eq(token)
    end
  end

  shared_examples 'se levanta un error de sintaxis' do
    it 'se levanta un error de sintaxis' do
      expect { FlechaLexer.new.tokenize(string) }.to raise_error(RLTK::LexingError)
    end
  end

  shared_examples 'secuencias de escape generan un token' do |token|
    context 'secuencia de escape de comilla simple' do
      let(:contenido) { "\\'" }

      include_examples 'se genera un token', token
    end

    context 'secuencia de escape de comilla doble' do
      let(:contenido) { '\\"' }

      include_examples 'se genera un token', token
    end

    context 'secuencia de escape de contrabarra' do
      let(:contenido) { '\\' }

      include_examples 'se genera un token', token
    end

    context 'secuencia de escape de tab' do
      let(:contenido) { '\\t' }

      include_examples 'se genera un token', token
    end

    context 'secuencia de escape de salto de linea' do
      let(:contenido) { '\\n' }

      include_examples 'se genera un token', token
    end

    context 'secuencia de escape de retorno de carro' do
      let(:contenido) { '\\r' }

      include_examples 'se genera un token', token
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

  context 'cuando hay retornos de carro' do
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

  context 'cuando hay una constante numérica' do
    let(:string) { '123456789' }

    include_examples 'se genera un token', :NUMBER
  end

  context 'cuando hay una constante de caracter' do
    let(:string) { "'#{contenido}'" }

    context 'un caracter o número' do
      let(:contenido) { 'u' }

      include_examples 'se genera un token', :CHAR
    end

    context 'secuencia de caracteres' do
      let(:contenido) { 'varios' }

      include_examples 'se levanta un error de sintaxis'
    end

    include_examples 'secuencias de escape generan un token', :CHAR
  end

  context 'cuando hay una constante de string' do
    let(:string) { "\"#{contenido}\"" }

    context 'secuencia de caracteres' do
      let(:contenido) { 'secuencia de caracteres' }

      include_examples 'se genera un token', :STRING
    end

    include_examples 'secuencias de escape generan un token', :STRING
  end

  context 'cuando hay una definición' do
    let(:string) { 'def' }

    include_examples 'se genera un token', :DEF
  end

  context 'cuando hay una alternativa condicional if' do
    let(:string) { 'if' }

    include_examples 'se genera un token', :IF
  end

  context 'cuando hay una alternativa condicional then' do
    let(:string) { 'then' }

    include_examples 'se genera un token', :THEN
  end

  context 'cuando hay una alternativa condicional elif' do
    let(:string) { 'elif' }

    include_examples 'se genera un token', :ELIF
  end

  context 'cuando hay una alternativa condicional else' do
    let(:string) { 'else' }

    include_examples 'se genera un token', :ELSE
  end

  context 'cuando hay pattern matching' do
    let(:string) { 'case' }

    include_examples 'se genera un token', :CASE
  end

  context 'cuando hay una declaración local let' do
    let(:string) { 'let' }

    include_examples 'se genera un token', :LET
  end

  context 'cuando hay una declaración local in' do
    let(:string) { 'in' }

    include_examples 'se genera un token', :IN
  end
end