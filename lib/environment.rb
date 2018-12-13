class Environment
  def initialize
    @stack = [
        { '__free_variables__': [], '__lambda_argument__': nil }
    ]
  end

  def create_scope_with(variable, value)
    @stack << current_scope.merge({ variable => value, '__free_variables__': [], '__lambda_argument__': nil })
  end

  def remove_current_scope
    @stack.pop
  end

  def add_to_current_scope(variable, value)
    current_scope.merge!({ variable => value })
  end

  def has_variable_defined_in_current_scope?(variable)
    @stack.any? { |scope| scope.has_key?(variable) }
  end

  def variable_latest_value(variable)
    scope_with_latest_variable_declaration = @stack.reverse.find { |scope| scope.has_key?(variable) }
    scope_with_latest_variable_declaration[variable]
  end

  def add_free_variable_to_current_scope(variable)
    current_scope[:__free_variables__] << variable
  end

  def free_variables_in_current_scope
    current_scope[:__free_variables__]
  end

  def add_lambda_argument_to_current_scope(argument)
    current_scope[:__lambda_argument__] = argument
  end

  def lambda_argument_in_current_scope
    current_scope[:__lambda_argument__]
  end

  private

  def current_scope
    @stack.last
  end
end