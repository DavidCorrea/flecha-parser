require 'rltk/lexer'

class FlechaLexer < RLTK::Lexer
  rule(/\s/)     # Espacios.
  rule(/--.*\n/) # Comentarios

  rule(/[a-z][_a-zA-Z0-9]*/) { :LOWERID } # Variables, constantes y funciones.
  rule(/[A-Z][_a-zA-Z0-9]*/) { :UPPERID } # Constructores.

  def tokenize(string)
    tokens = self.lex(string)
    tokens.delete_if { |token| token.type.eql? :EOS }
    tokens
  end
end