require_relative 'lib/flecha_lexer'
require_relative 'lib/flecha_parser'
require 'colorize'

def info(output)
  puts output.blue
end

def success(output)
  puts output.green
end

def warning(output)
  puts output.red
end

def print_tokens(tokens)
  puts tokens.map { |token| token.type }.to_s.gsub(' ', '').gsub("\n", '')
end

task :lex_test_file, [:filename] do |_, args|
  info "Lexing '#{args[:filename]}'..."
  tokens = FlechaLexer.new.lex_file("spec/test_files/#{args[:filename]}.input")
  print_tokens(tokens)
end

task :parse_test_file, [:filename] do |_, args|
  info "Lexing '#{args[:filename]}'..."
  tokens = FlechaLexer.new.lex_file("spec/test_files/#{args[:filename]}.input")

  info "Parsing '#{args[:filename]}'..."
  parse_result = FlechaParser.new.parse(tokens)

  print parse_result

  expected = File.open("spec/test_files/#{args[:filename]}.expected").read.gsub(' ', '').gsub("\n", '')
  result = parse_result.to_s.gsub(' ', '').gsub("\n", '')

  puts "\n"
  puts result == expected ? success('Result matches expected') : warning('Wrong result')
end

task :lex_file, [:path] do |_, args|
  info "Lexing file from '#{args[:path]}'..."
  tokens = FlechaLexer.new.lex_file(args[:path])
  print_tokens(tokens)
end

task :parse_file, [:path] do |_, args|
  info "Lexing file from '#{args[:path]}'..."
  tokens = FlechaLexer.new.lex_file(args[:path])

  info "Parsing file from '#{args[:path]}'..."
  parse_result = FlechaParser.new.parse(tokens)

  print parse_result
end