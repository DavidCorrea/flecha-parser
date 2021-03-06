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
  rule(/[a-z][_a-zA-Z0-9]*/) { |id| [:LOWERID, id] }
  rule(/[A-Z][_a-zA-Z0-9]*/) { |id| [:UPPERID, id] }

  # Constantes numéricas
  rule(/[0-9]+/) { | number | [:NUMBER, number.to_i] }

  # Constantes de caracter
  rule(/'(\\"|\\'|\\\\|\s|\\t|\\n|\\r|[^'])'/) { | character | [:CHAR, character.gsub("'", '').ord] }

  # Constantes de string
  rule(/"(\\"|\\'|\\\\|\s|\\t|\\n|\\r|[^"])*"/) { | string | [:STRING, string.gsub('"', '')] }
end