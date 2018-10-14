require_relative 'lib/flecha_lexer'

task :tokens_de_archivo, [:filename] do | task, args |
  tokens = FlechaLexer.new.lex_file("spec/test_files/#{args[:filename]}.input")

  p "Tokens: #{tokens.map { |token| token.type }}"
end