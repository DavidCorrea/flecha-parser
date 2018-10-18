require_relative 'lib/flecha_lexer'
require_relative 'lib/flecha_parser'
require 'pp'

task :lex_test_file, [:test_filename] do | task, args |
  pp "Lexing '#{args[:filename]}'..."
  tokens = FlechaLexer.new.lex_file("spec/test_files/#{args[:test_filename]}.input")

  pp tokens.map { |token| token.type }
end

task :parse_test_file, [:filename] do | task, args |
  pp "Lexing '#{args[:filename]}'..."
  tokens = FlechaLexer.new.lex_file("spec/test_files/#{args[:test_filename]}.input")

  pp "Parsing '#{args[:filename]}'..."
  parse_result = FlechaParser.new.parse(tokens)

  pp parse_result
end

task :lex_file, [:path] do | task, args |
  pp "Lexing file from '#{args[:path]}'..."
  tokens = FlechaLexer.new.lex_file(args[:path])

  pp tokens.map { |token| token.type }
end

task :parse_file, [:path] do | task, args |
  pp "Lexing file from '#{args[:path]}'..."
  tokens = FlechaLexer.new.lex_file(args[:path])

  pp "Parsing file from '#{args[:path]}'..."
  parse_result = FlechaParser.new.parse(tokens)

  pp parse_result
end