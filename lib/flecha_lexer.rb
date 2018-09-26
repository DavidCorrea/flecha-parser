require 'rltk/lexer'

class FlechaLexer < RLTK::Lexer
  # Espacios
  rule(/\s/)

  # Comentarios
  rule(/--.*\n/)

  # Definiciones - ¿Esta bien ponerlo antes que LOWERID?
  rule(/def/) { :DEF }

  # Alternativa Condicional - if
  rule(/if/) { :IF }

  # Alternativa Condicional - then
  rule(/then/) { :THEN }

  # Alternativa Condicional - elif
  rule(/elif/) { :ELIF }

  # Alternativa Condicional - else
  rule(/else/) { :ELSE }

  # Pattern Matching
  rule(/case/) { :CASE }

  # Declaración Local - let
  rule(/let/) { :LET }

  # Declaración Local - in
  rule(/in/) { :IN }

  # Asignación
  rule(/=/) { :DEFEQ }

  # Secuenciación
  rule(/;/) { :SEMICOLON }

  # Comienzo de agrupación de expresiones
  rule(/\(/) { :LPAREN }

  # Final de agrupación de expresiones
  rule(/\)/) { :RPAREN }

  # Declaración de función anónima
  rule(/\\/) { :LAMBDA }

  # Declaración de cuerpo de función anónima
  rule(/->/) { :ARROW }

  # Declaración de rama de un case
  rule(/\|/) { :PIPE }

  # Variables, constantes y funciones
  rule(/[a-z][_a-zA-Z0-9]*/) { :LOWERID }

  # Constructores
  rule(/[A-Z][_a-zA-Z0-9]*/) { :UPPERID }

  # Constante numérica
  rule(/[0-9]+/) { :NUMBER }

  # Constante de caracter
  rule(/'([_a-zA-Z0-9]|\\'|\\"|\\|\\t|\\n|\\r)'/) { :CHAR }

  # Constante de string
  rule(/"([_a-zA-Z0-9 ]+|\\'|\\"|\\|\\t|\\n|\\r)"/) { :STRING }

  def tokenize(string)
    tokens = self.lex(string)
    tokens.delete_if { |token| token.type.eql? :EOS }
    tokens
  end
end