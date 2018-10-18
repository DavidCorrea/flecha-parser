require_relative 'lib/flecha_lexer'
require_relative 'lib/flecha_parser'
require 'pp'
require 'colorize'

task :lex_test_file, [:test_filename] do |task, args|
  pp "Lexing '#{args[:filename]}'..."
  tokens = FlechaLexer.new.lex_file("spec/test_files/#{args[:filename]}.input")

  pp tokens.map { |token| token.type }
end

task :parse_test_file, [:filename] do |task, args|
  pp "Lexing '#{args[:filename]}'..."
  tokens = FlechaLexer.new.lex_file("spec/test_files/#{args[:filename]}.input")

  pp "Parsing '#{args[:filename]}'..."
  parse_result = FlechaParser.new.parse(tokens)

  print parse_result

  expected = File.open("spec/test_files/#{args[:filename]}.expected").read.gsub(' ', '').gsub("\n", '')
  result = parse_result.to_s.gsub(' ', '').gsub("\n", '')

  puts "\n"
  puts result == expected ? 'Result matches expected'.green : 'Wrong result'.red
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