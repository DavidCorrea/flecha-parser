require 'spec_helper'
require_relative '../lib/flecha_lexer'

describe 'Flecha Lexer' do
  shared_examples 'no se genera ningún token' do
    it 'no se genera ningún token' do
      tokens = FlechaLexer.new.lex(string)

      expect(tokens.size).to eq(1) # EOS Token siempre se genera.
    end
  end

  shared_examples 'se genera un token' do | token |
    it 'se genera un token' do
      tokens = FlechaLexer.new.lex(string)
      expect(tokens.size).to eq(2) # EOS Token siempre se genera.

      tokens_types = tokens.map(&:type)
      expect(tokens_types).to include(token)
    end
  end

  shared_examples 'se levanta un error de sintaxis' do
    it 'se levanta un error de sintaxis' do
      expect { FlechaLexer.new.lex(string) }.to raise_error(RLTK::LexingError)
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
      let(:contenido) { '\\\\' }

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

    context 'con un caracter o número' do
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

    context 'sin contenido' do
      let(:contenido) { '' }

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

  context 'cuando hay una asignación' do
    let(:string) { '=' }

    include_examples 'se genera un token', :DEFEQ
  end

  context 'cuando hay una secuenciación' do
    let(:string) { ';' }

    include_examples 'se genera un token', :SEMICOLON
  end

  context 'cuando hay un comienzo de agrupación de expresiones' do
    let(:string) { '(' }

    include_examples 'se genera un token', :LPAREN
  end

  context 'cuando hay un final de agrupación de expresiones' do
    let(:string) { ')' }

    include_examples 'se genera un token', :RPAREN
  end

  context 'cuando hay una definición de función anónima' do
    let(:string) { '\\' }

    include_examples 'se genera un token', :LAMBDA
  end

  context 'cuando hay una rama de un case' do
    let(:string) { '|' }

    include_examples 'se genera un token', :PIPE
  end

  context 'cuando hay una definición del cuerpo de una función anónima' do
    let(:string) { '->' }

    include_examples 'se genera un token', :ARROW
  end

  context 'cuando hay una conjunción' do
    let(:string) { '&&' }

    include_examples 'se genera un token', :AND
  end

  context 'cuando hay una disyunción' do
    let(:string) { '||' }

    include_examples 'se genera un token', :OR
  end

  context 'cuando hay una negación' do
    let(:string) { '!' }

    include_examples 'se genera un token', :NOT
  end

  context 'cuando hay una igualdad' do
    let(:string) { '==' }

    include_examples 'se genera un token', :EQ
  end

  context 'cuando hay una desigualdad' do
    let(:string) { '!=' }

    include_examples 'se genera un token', :NE
  end

  context 'cuando hay una comparación por mayor o igual' do
    let(:string) { '>=' }

    include_examples 'se genera un token', :GE
  end

  context 'cuando hay una comparación por menor o igual' do
    let(:string) { '<=' }

    include_examples 'se genera un token', :LE
  end

  context 'cuando hay una comparación por mayor estricto' do
    let(:string) { '>' }

    include_examples 'se genera un token', :GT
  end

  context 'cuando hay una comparación por menor estricto' do
    let(:string) { '<' }

    include_examples 'se genera un token', :LT
  end

  context 'cuando hay una suma' do
    let(:string) { '+' }

    include_examples 'se genera un token', :PLUS
  end

  context 'cuando hay una resta' do
    let(:string) { '-' }

    include_examples 'se genera un token', :MINUS
  end

  context 'cuando hay una multiplicación' do
    let(:string) { '*' }

    include_examples 'se genera un token', :TIMES
  end

  context 'cuando hay una división' do
    let(:string) { '/' }

    include_examples 'se genera un token', :DIV
  end

  context 'cuando hay un resto' do
    let(:string) { '%' }

    include_examples 'se genera un token', :MOD
  end

  context 'paréntesis izquierdo' do
    let(:string) { '(' }

    include_examples 'se genera un token', :LPAREN
  end

  context 'paréntesis derecho' do
    let(:string) { ')' }

    include_examples 'se genera un token', :RPAREN
  end
end