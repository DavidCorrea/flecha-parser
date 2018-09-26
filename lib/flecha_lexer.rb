require 'rltk/lexer'

class FlechaLexer < RLTK::Lexer
  # Blancos y Comentarios
  rule(/\s/)
  rule(/--.*\n/)

  # Definiciones
  rule(/def/) { :DEF }

  # Alternativa Condicional
  rule(/if/) { :IF }
  rule(/then/) { :THEN }
  rule(/elif/) { :ELIF }
  rule(/else/) { :ELSE }

  # Pattern Matching
  rule(/case/) { :CASE }

  # Declaración Local
  rule(/let/) { :LET }
  rule(/in/) { :IN }

  # Delimitadores
  rule(/=/) { :DEFEQ }
  rule(/;/) { :SEMICOLON }
  rule(/\(/) { :LPAREN }
  rule(/\)/) { :RPAREN }
  rule(/\\/) { :LAMBDA }
  rule(/->/) { :ARROW }
  rule(/\|/) { :PIPE }

  # Operadores lógicos
  rule(/&&/) { :AND }
  rule(/\|\|/) { :OR }
  rule(/!/) { :NOT }

  # Operadores relacionales
  rule(/==/) { :EQ }
  rule(/!=/) { :NE }
  rule(/>=/) { :GE }
  rule(/<=/) { :LE }
  rule(/>/) { :GT }
  rule(/</) { :LT }

  # Operadores aritméticos
  rule(/\+/) { :PLUS }
  rule(/-/) { :MINUS }
  rule(/\*/) { :TIMES }
  rule(/\//) { :DIV }
  rule(/%/) { :MOD }

  # Identificadores
  rule(/[a-z][_a-zA-Z0-9]*/) { :LOWERID }
  rule(/[A-Z][_a-zA-Z0-9]*/) { :UPPERID }

  # Constantes numéricas
  rule(/[0-9]+/) { :NUMBER }

  # Constantes de caracter
  rule(/'([_a-zA-Z0-9]|\\'|\\"|\\|\\t|\\n|\\r)'/) { :CHAR }

  # Constantes de string
  rule(/"([_a-zA-Z0-9 ]+|\\'|\\"|\\|\\t|\\n|\\r)"/) { :STRING }

  def tokenize(string)
    tokens = self.lex(string)
    tokens.delete_if { |token| token.type.eql? :EOS }
    tokens
  end
end