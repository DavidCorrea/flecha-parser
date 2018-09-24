require 'flecha_lexer'

class FlechaReader
  def initialize
    @evaluator = FlechaLexer.new
  end

  def leer(input)
    @evaluator.tokenize(input) # Input.
  end
end