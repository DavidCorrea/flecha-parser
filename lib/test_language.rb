require 'lexer'

class TestLanguageTester
  @evaluator = TestLanguage.new
  @evaluator.tokenize("u")
end