require 'rltk/lexer'

class FlechaLexer < RLTK::Lexer
  # Espacios.
  rule(/\s/)

  # Comentarios
  rule(/--.*\n/)

  # Variables, constantes y funciones.
  rule(/[a-z][_a-zA-Z0-9]*/) { :LOWERID }

  # Constructores.
  rule(/[A-Z][_a-zA-Z0-9]*/) { :UPPERID }

  # Constante numérica.
  rule(/[0-9]+/) { :NUMBER }

  # Constante de caracter.
  rule(/'([_a-zA-Z0-9]+|\\'|\\"|\\|\\t|\\n|\\r)'/) { :CHAR }

  def tokenize(string)
    tokens = self.lex(string)
    tokens.delete_if { |token| token.type.eql? :EOS }
    tokens
  end
end