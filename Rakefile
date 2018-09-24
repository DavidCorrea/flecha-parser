Rake.application.rake_require 'oedipus_lex'

task :lexer  => 'lib/lexer.rb'
task :parser => :lexer # Plus appropriate parser rules/deps.
task :test   => :parser