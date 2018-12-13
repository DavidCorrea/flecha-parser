# flecha-parser
Analizador sintáctico para el lenguaje de programación funcional Flecha - Parseo y Generación de Código - 2do Semestre 2018

## Pasos previos

- `\curl -sSL https://get.rvm.io | bash -s stable`
- `rvm install 2.4.1`
- `gem install bundle`
- `bundle install`

## Aclaraciones para usar las tareas de Compile/Interpret
- Para poder usar el Interprete dentro de las tareas, se debe compilar `mamarracho.cpp` bajo el nombre `mamarracho` en la carpeta `lib/interpreter/`:
- `g++ -o ./lib/interpreter/mamarracho ./lib/interpreter/mamarracho.cpp`

## Tareas disponibles
- `rspec .` - Corre la suite de specs.

- `rake lex_test_file[nombre_de_test_file]` - (`nombre_de_test_file` ubicado en `spec/parser_test_files`, por ejemplo, `test00`) Muestra los Tokens generados por el Lexer al analizar el archivo.
Ejemplo: `rake lex_test_file['test00']`
 
- `rake parse_test_file[nombre_de_test_file]` - (`nombre_de_test_file` ubicado en `spec/parser_test_files`, por ejemplo, `test00`) Muestra el JSON producido al parsear el archivo.
Ejemplo: `rake parse_test_file['test00']`

- `rake compile_test_file[nombre_de_test_file]` - (`nombre_de_test_file` ubicado en `spec/compiler_test_files`, por ejemplo, `test01`) Compila e imprime las instrucciones generadas.
Ejemplo: `rake compile_test_file_instructions['test01']`

- `rake interpret_test_file[nombre_de_test_file]` - (`nombre_de_test_file` ubicado en `spec/compiler_test_files`, por ejemplo, `test01`) Compila y envia el código al Interprete para ejecutarlo.
Ejemplo: `rake interpret_test_file['test01']`
 
- `rake lex_file[path_al_archivo]` - Muestra los Tokens generados por el Lexer al analizar el archivo ubicado en el path indicado.
Ejemplo: `rake lex_file['./spec/parser_test_files/test00.input']`

- `rake parse_file[path_al_archivo]` - Muestra el JSON producido al parsear el archivo ubicado en el path indicado.
Ejemplo: `rake parse_file['./spec/parser_test_files/test00.input']`

- `rake compile_file[path_al_archivo]` - Compila el .fl ubicado en el path indicado e imprime las instrucciones generadas.
Ejemplo: `rake compile_file['./spec/compiler_test_files/test01.fl']`

- `rake interpret_file[path_al_archivo]` - Compila el .fl ubicado en el path indicado y envia el código al Interprete para ejecutarlo.
Ejemplo: `rake compile_file_instructions['./spec/compiler_test_files/test01.fl']`