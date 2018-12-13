require_relative 'lib/flecha_lexer'
require_relative 'lib/flecha_parser'
require_relative 'lib/compiler'
require 'colorize'
require 'tempfile'

task :lex_test_file, [:filename] do |_, args|
  print_tokens(lex(parser_test_file(args[:filename])))
end

task :parse_test_file, [:filename] do |_, args|
  parse_result = parse(parser_test_file(args[:filename]))

  print parse_result

  expected = File.open(expected_parser_test_file(args[:filename])).read.gsub(' ', '').gsub("\n", '')
  result = parse_result.to_s.gsub(' ', '').gsub("\n", '')

  puts "\n"
  puts result == expected ? success('Result matches expected') : warning('Wrong result')
end

task :compile_test_file, [:filename] do |_, args|
  print compile(compiler_test_file(args[:filename]))
end

task :interpret_test_file, [:filename] do |_, args|
  interpret(compiler_test_file(args[:filename]))
end

task :lex_file, [:path] do |_, args|
  print_tokens(lex(args[:path]))
end

task :parse_file, [:path] do |_, args|
  print parse(args[:path])
end

task :compile_file, [:path] do |_, args|
  print compile(args[:path])
end

task :interpret_file, [:path] do |_, args|
  interpret(args[:path])
end

def info(output)
  puts output.blue
end

def success(output)
  puts output.green
end

def warning(output)
  puts output.red
end

def parser_test_file(filename)
  "spec/parser_test_files/#{filename}.input"
end

def expected_parser_test_file(filename)
  "spec/parser_test_files/#{filename}.expected"
end

def compiler_test_file(filename)
  "spec/compiler_test_files/#{filename}.fl"
end

def print_tokens(tokens)
  puts tokens.map { |token| token.type }.to_s.gsub(' ', '').gsub("\n", '')
end

def lex(filename)
  info "Lexing '#{filename}'..."
  FlechaLexer.new.lex_file(filename)
end

def parse(filename)
  tokens = lex(filename)

  info "Parsing '#{filename}'..."
  FlechaParser.new.parse(tokens)
end

def compile(filename)
  parsed = parse(filename)

  info "Compiling '#{filename}'..."
  Compiler.new.compile(parsed)
end

def interpret(filename)
  compiled = compile(filename)

  file = Tempfile.new('foo')

  begin
    file.write(compiled)
    file.rewind

    info "Interpreting '#{filename}'..."
    sh("./lib/interpreter/mamarracho #{file.path} && printf '\n'", verbose: false)
  rescue
    warning('Uh oh...')
  ensure
    file.close
    file.unlink
  end
end