# flecha-parser
Analizador sintáctico para el lenguaje de programación funcional Flecha - Parseo y Generación de Código - 2do Semestre 2018

## Pasos previos

- `\curl -sSL https://get.rvm.io | bash -s stable`
- `rvm install 2.4.1`
- `gem install bundle`
- `bundle install`

## Tareas disponibles
- `rspec .` - Corre todos los specs.

- `rake lex_test_file[nombre_de_test_file]` - (`nombre_de_test_file` debe ser, por ejemplo, `test00`) Muestra los Tokens generados por el Lexer al analizar el archivo.
Ejemplo: `rake lex_test_file['test00']`
 
- `rake parse_test_file[nombre_de_test_file]` - (`nombre_de_test_file` debe ser, por ejemplo, `test00`) Muestra el JSON producido al parsear el archivo.
Ejemplo: `rake parse_test_file['test00']`
 
- `rake lex_file[path_al_archivo]` - Muestra los Tokens generados por el Lexer al analizar el archivo ubicado en el path indicado.
Ejemplo: `rake lex_file['./spec/test_files/test00.input']`

- `rake parse_file[path_al_archivo]` - Muestra el JSON producido al parsear el archivo ubicado en el path indicado.
Ejemplo: `rake parse_file['./spec/test_files/test00.input']`