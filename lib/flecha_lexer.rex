class FlechaLexer
macro
  BLANK          \s
  TAB            \t
  SALTO_DE_LINEA \n
  RETORNO_CARRO  [\\r\t]+
  COMENTARIO     [\--.*\t]+

rule
  {BLANK}          # Nada que hacer.
  {TAB}            # Nada que hacer.
  {SALTO_DE_LINEA} # Nada que hacer.
  {RETORNO_CARRO}  # Nada que hacer.
  {COMENTARIO}     # Nada que hacer.

inner
  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end