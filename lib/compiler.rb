require_relative 'environment'

class Compiler

  TEMP_REGISTER = '$t'

  GLOBAL_REGISTER_PREFIX = '@'
  LOCAL_REGISTER_PREFIX = '$'
  ROUTINE_PREFIX = 'rtn_'

  TEMPORARY_POSTFIX = 'tmp'
  FUNCTION_POSTFIX = 'fun'
  ARGUMENTS_POSTFIX = 'arg'
  RESULT_POSTFIX = 'res'

  INT_TAG = 1
  CHAR_TAG = 2
  CLOSURE_TAG = 3
  TRUE_TAG = 4
  FALSE_TAG = 5
  NIL_TAG = 6
  CONS_TAG = 7

  UNSAFE_PRINT_INT = 'unsafePrintInt'
  UNSAFE_PRINT_CHAR = 'unsafePrintChar'

  def initialize
    @register_index = 0
    @temporary_register_index = 0
    @routine_index = 0

    @environment = Environment.new
  end

  def compile(program, compiled = '')
    program.reduce(compiled) do |result, instructions|
      instruction_token = instructions[0]

      if instruction_token == 'True'
        compile_isolated_constructor_with tag: TRUE_TAG
      elsif instruction_token == 'False'
        compile_isolated_constructor_with tag: FALSE_TAG
      elsif instruction_token == 'Nil'
        compile_isolated_constructor_with tag: NIL_TAG
      elsif instruction_token == 'ExprChar'
        instruction_value = instructions[1]
        compile_primitive(CHAR_TAG, instruction_value.ord)
      elsif instruction_token == 'ExprNumber'
        instruction_value = instructions[1]
        compile_primitive(INT_TAG, instruction_value)
      elsif instruction_token == 'ExprVar'
        compile_variable(instructions)
      elsif instruction_token == 'ExprLet'
        compile_let(instructions, result)
      elsif instruction_token == 'Def'
        compile_def(instructions, result)
      elsif instruction_token == 'ExprLambda'
        compile_lambda(instructions, result)
      elsif instruction_token == 'ExprApply'
        compile_application(instructions, result)
      elsif instruction_token == 'ExprConstructor'
        compile([["ExprLambda", "#_x", ["ExprLambda", "#_y", %w(ExprCons Cons)]]], result)
      elsif instruction_token == 'ExprCons'
        compile_cons
      end
    end
  end

  private

  def compile_primitive(primitive_tag, primitive_value)
    @last_used = fresh_register

    generate_output([
      alloc(@last_used, 2),
      mov_int(TEMP_REGISTER, primitive_tag),
      store(@last_used, 0, TEMP_REGISTER),
      mov_int(TEMP_REGISTER, primitive_value),
      store(@last_used, 1, TEMP_REGISTER)
    ])
  end

  def compile_isolated_constructor_with(tag:)
    @last_used = fresh_register

    generate_output([
      alloc(@last_used, 1),
      mov_int(TEMP_REGISTER, tag),
      store(@last_used, 0, TEMP_REGISTER)
    ])
  end

  def compile_def(instructions, result)
    def_name = instructions[1]
    def_body = instructions[2]

    result.concat(generate_output([
      compile([def_body], result),
      mov_reg(global_user_register(def_name), @last_used),
      ''
    ]))
  end

  def compile_variable(instructions)
    variable_name = instructions[1]

    if variable_name == UNSAFE_PRINT_INT
      loaded = fresh_register

      generate_output([load(loaded, @last_used, 1), print(loaded)])
    elsif variable_name == UNSAFE_PRINT_CHAR
      loaded = fresh_register

      generate_output([load(loaded, @last_used, 1), print_char(loaded)])
    else
      @last_used = fresh_register

      if @compiling_routine
        if @environment.lambda_argument_in_current_scope == variable_name
          mov_reg(@last_used, fetch_from_context(variable_name))
        else
          @environment.add_to_current_scope(variable_name, @last_used)
          @environment.add_free_variable_to_current_scope(variable_name)

          load(@last_used, local_function_register, @environment.free_variables_in_current_scope.size + 1)
        end
      else
        mov_reg(@last_used, fetch_from_context(variable_name))
      end
    end
  end

  def compile_let(instructions, result)
    variable = instructions[1]
    variable_definition = instructions[2]
    let_body = instructions[3]

    @compiling_let = true
    compiled_variable_definition = compile([variable_definition], result)
    @compiling_let = false

    @environment.create_scope_with(variable, @last_used)
    compiled_let_body = compile([let_body], result)
    @environment.remove_current_scope

    generate_output([
      compiled_variable_definition,
      compiled_let_body
    ])
  end

  def compile_lambda(instructions, result)
    argument = instructions[1]
    lambda_body = instructions[2]
    routine_name = fresh_routine_name
    @environment.create_scope_with(argument, local_arguments_register)
    @environment.add_lambda_argument_to_current_scope(argument)
    @compiling_routine = true

    compiled_routine = generate_output([
      jump("end_#{routine_name}_definition"),
      label(routine_name),
      mov_reg(local_function_register, global_function_register),
      mov_reg(local_arguments_register, global_arguments_register),
      compile([lambda_body], result),
      mov_reg(local_result_register, @last_used),
      mov_reg(global_result_register, local_result_register),
      return_from_routine,
      label("end_#{routine_name}_definition"),
      ''
    ])

    @compiling_routine = false
    @last_used = routine_register = fresh_register

    compiled_routine_register = generate_output([
      alloc(routine_register, 3),
      mov_int(TEMP_REGISTER, CLOSURE_TAG),
      store(routine_register, 0, TEMP_REGISTER),
      mov_label(TEMP_REGISTER, routine_name),
      store(routine_register, 1, TEMP_REGISTER)
    ])

    compiled_routine_variables = @environment.free_variables_in_current_scope.each_with_index.map do |variable, index|
      generate_output([
          mov_reg(TEMP_REGISTER, fetch_from_context(variable)),
          store(routine_register, index + 2, TEMP_REGISTER)
      ])
    end

    @environment.remove_current_scope
    compiled_routine.concat(compiled_routine_register.concat(generate_output(compiled_routine_variables)))
  end

  def compile_application(instructions, result)
    if unsafe_printing?(instructions)
      generate_output([
        compile([instructions[2]], result),
        compile([instructions[1]], result)
      ])
    else
      closure = instructions[1]
      param = instructions[2]

      compiled_closure = compile([closure], result)
      closure_register = @last_used
      compiled_param = compile([param], result)
      param_register = @last_used

      @last_used = routine_register = fresh_register
      @last_used = result_register = fresh_register

      generate_output([
        compiled_closure,
        compiled_param,
        load(routine_register, closure_register, 1),
        mov_reg(global_function_register, closure_register),
        mov_reg(global_arguments_register, param_register),
        icall(routine_register),
        mov_reg(result_register, global_result_register)
      ])
    end
  end

  def compile_cons
    fun_register = fresh_register
    @last_used = fresh_register

    generate_output([
      load(fun_register, local_function_register, 2),
      alloc(@last_used, 3),
      mov_int(TEMP_REGISTER, CONS_TAG),
      store(@last_used, 0, TEMP_REGISTER),
      store(@last_used, 1, local_arguments_register),
      store(@last_used, 2, fun_register)
    ])
  end

  def fetch_from_context(variable)
    if @environment.has_variable_defined_in_current_scope?(variable)
      @environment.variable_latest_value(variable)
    else
      global_user_register(variable)
    end
  end

  def fresh_register
    if @compiling_let
      fresh = @temporary_register_index
      @temporary_register_index += 1

      temporary_register(fresh)
    else
      fresh = @register_index
      @register_index += 1

      local_register("r#{fresh}")
    end
  end

  def fresh_routine_name
    @routine_index += 1

    "#{ROUTINE_PREFIX}#{@routine_index}"
  end

  def unsafe_printing?(instructions)
    instructions[1][1] == UNSAFE_PRINT_INT || instructions[1][1] == UNSAFE_PRINT_CHAR
  end

  def scoped_variable(variable, depth)
    "#{variable}_#{depth}"
  end

  def generate_output(instructions)
    instructions.join("\n")
  end

  def global_user_register(register_name)
    "#{GLOBAL_REGISTER_PREFIX}G_#{register_name}"
  end

  def local_register(register_name)
    "#{LOCAL_REGISTER_PREFIX}#{register_name}"
  end

  def temporary_register(register_name)
    "#{LOCAL_REGISTER_PREFIX}#{TEMPORARY_POSTFIX}_#{register_name}"
  end

  def global_result_register
    "#{GLOBAL_REGISTER_PREFIX}#{RESULT_POSTFIX}"
  end

  def local_result_register
    "#{LOCAL_REGISTER_PREFIX}#{RESULT_POSTFIX}"
  end

  def global_function_register
    "#{GLOBAL_REGISTER_PREFIX}#{FUNCTION_POSTFIX}"
  end

  def local_function_register
    "#{LOCAL_REGISTER_PREFIX}#{FUNCTION_POSTFIX}"
  end

  def global_arguments_register
    "#{GLOBAL_REGISTER_PREFIX}#{ARGUMENTS_POSTFIX}"
  end

  def local_arguments_register
    "#{LOCAL_REGISTER_PREFIX}#{ARGUMENTS_POSTFIX}"
  end

  def label(label_name)
    "#{label_name}:"
  end

  def mov_reg(to_register, from_register)
    "mov_reg(#{to_register}, #{from_register})"
  end

  def mov_int(register, integer)
    "mov_int(#{register}, #{integer})"
  end

  def mov_label(register, label_name)
    "mov_label(#{register}, #{label_name})"
  end

  def alloc(register, number_of_slots)
    "alloc(#{register}, #{number_of_slots})"
  end

  def load(to_register, from_register, from_register_slot_index)
    "load(#{to_register}, #{from_register}, #{from_register_slot_index})"
  end

  def store(to_register, to_register_slot_index, register_to_store)
    "store(#{to_register}, #{to_register_slot_index}, #{register_to_store})"
  end

  def print(register)
    "print(#{register})"
  end

  def print_char(register)
    "print_char(#{register})"
  end

  def jump(label_to_jump_to)
    "jump(#{label_to_jump_to})"
  end

  def jump_eq(register_1, register_2, label_to_jump_to)
    "jump_eq(#{register_1}, #{register_2}, #{label_to_jump_to})"
  end

  def jump_lt(register_1, register_2, label_to_jump_to)
    "jump_lt(#{register_1}, #{register_2}, #{label_to_jump_to})"
  end

  def add(result_register, register_1, register_2)
    "add(#{result_register}, #{register_1}, #{register_2})"
  end

  def sub(result_register, register_1, register_2)
    "sub(#{result_register}, #{register_1}, #{register_2})"
  end

  def mul(result_register, register_1, register_2)
    "mul(#{result_register}, #{register_1}, #{register_2})"
  end

  def div(result_register, register_1, register_2)
    "div(#{result_register}, #{register_1}, #{register_2})"
  end

  def mod(result_register, register_1, register_2)
    "mod(#{result_register}, #{register_1}, #{register_2})"
  end

  def call(label)
    "call(#{label})"
  end

  def icall(register)
    "icall(#{register})"
  end

  def return_from_routine
    'return()'
  end
end