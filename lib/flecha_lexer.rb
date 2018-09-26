require 'rltk/lexer'

class FlechaLexer < RLTK::Lexer
  rule(/\s/)     # Espacios.
  rule(/--.*\n/) # Comentarios

  def tokenize(string)
    self.lex(string)
  end
end