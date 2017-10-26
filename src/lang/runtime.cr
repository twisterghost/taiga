require "./stdlib"
include StdLib

module Lang
  abstract class Value
    property type : Symbol
    property value : VariableValue

    def initialize(type, value)
      @type = type
      @value = value
    end

    def print
      @value.to_s
    end
  end

  class ValString < Value
    def value
      if @value.is_a?(String)
        return @value
      end
      raise Exception.new("Runtime error: Internal string rep isnt a string")
    end
  end

  class ValNumber < Value
    def value
      val = @value
      if val.is_a?(Float64)
        return val.to_f64
      end
      raise Exception.new("Runtime error: Internal number rep isnt a number")
    end
  end

  class ValBool < Value
    def initialize(type : Symbol, value : VariableValue)
      @type = type
      @value = value
    end

    def initialize(type : Symbol, value : Bool)
      @type = type
      if value
        @value = 1
      else
        @value = 0
      end
    end

    def value
      if @value == 1
        return true
      else
        return false
      end
    end

    def print
      if @value == 1
        return "true"
      else
        return "false"
      end
    end
  end

  class ValCommand < Value
    def value
      @value.to_s
    end
  end

  class ValHash < Value
    def initialize(type)
      @type = type
      @value = {} of String => Value
    end

    def print
      str = ""
      hash_value = @value
      if hash_value.is_a?(Hash(String, Value))
        hash_value.each do |key, item|
          str += key + ": " + item.print + ", "
        end
      end
      str
    end
  end

  class Arguments
    property values : Array(Value)

    def initialize(raw : Array(Literal | Token), context : RoutRunner)
      @values = [] of Value
      raw.each do |arg|
        @values.push(context.value_of(arg))
      end
    end
  end

  class RoutRunner
    property variables : Hash(String, Value)
    property rout : Routine
    property context : Runtime
    property terminated : Bool

    def initialize(rout : Routine, context : Runtime)
      @rout = rout
      @variables = {} of String => Value
      @variables["_"] = ValBool.new(:bool, 1)
      @context = context
      @lastif = false
      @terminated = false
    end

    def get_var(name : String)
      if @variables.has_key?(name)
        return @variables[name]
      end

      if @context.program.routines.has_key?(name)
        return ValCommand.new(:command, name)
      end

      return nil
    end

    def evaluate_dynamic(parts : Array(Literal | Token))
      if parts.size == 0
        raise Exception.new("Runtime error: Cannot execute nothing")
      end

      potential_command = parts[0]
      if potential_command.is_a?(Token)
        check_command = value_of(potential_command)
        if check_command.nil?
          command = Command.new(potential_command.name)
        else
          command = Command.new(check_command.value.to_s)
        end

        if parts.size > 1
          command.arguments = parts[1..-1]
        end

        evaluate(command)
      elsif potential_command.is_a?(Value)
        save_res(potential_command)
      end
    end

    def evaluate(command : Command)
      run_command = command.command
      raw_arguments = command.arguments

      # Constant definition
      if run_command == "let"
        first_arg = raw_arguments[0]
        if first_arg.is_a?(Token)
          variable_name = first_arg.name
          value = value_of(raw_arguments[1])
          @variables[variable_name] = value
          save_res(value)
          return
        else
          raise Exception.new("Runtime error: Invalid variable name")
        end
      end

      if run_command == "default"
        first_arg = raw_arguments[0]
        if first_arg.is_a?(Token)
          variable_name = first_arg.name
          if !@variables.has_key?(variable_name)
            value = value_of(raw_arguments[1])
            @variables[variable_name] = value
            save_res(value)
          end
          return
        else
          raise Exception.new("Runtime error: Invalid variable name")
        end
      end

      # Flow control
      if run_command == "if"
        checkval = value_of(raw_arguments[0])
        if checkval.is_a?(ValBool)
          @lastif = checkval.value
          if @lastif
            evaluate_dynamic(raw_arguments[1..-1])
          end
          return
        else
          raise Exception.new("Runtime error: Cannot if on non-bool")
        end
      end

      if run_command == "elif"
        checkval = value_of(raw_arguments[0])
        if checkval.is_a?(ValBool)
          if !@lastif && checkval.value
            @lastif = true
            evaluate_dynamic(raw_arguments[1..-1])
          end
          return
        else
          raise Exception.new("Runtime error: Cannot if on non-bool")
        end
      end

      if run_command == "else"
        if !@lastif
          evaluate_dynamic(raw_arguments[0..-1])
        end
        return
      end

      if run_command == "return"
        @terminated = true
        if raw_arguments.size > 0
          save_res(value_of(raw_arguments[0]))
        end
        return
      end

      # Parse args and send to stdlib
      arguments = Arguments.new(raw_arguments, self)
      if (run_command == "_")
        possible_command = get_var("_")
        if possible_command.nil?
          raise Exception.new("Runtime error: Cannot run nonexistent routine")
        else
          run_command = possible_command.value.to_s
        end
      end

      # Check if the context has this command as a routine
      if @context.program.routines.has_key?(run_command)
        subrout = @context.program.routines[run_command]
        runner = RoutRunner.new(subrout, @context)
        save_res(runner.run(arguments.values))
      else
        save_res(StdLib.resolve(run_command, arguments))
      end

    end

    def save_res(res : Value)
      @variables["_"] = res
    end

    def value_of(var_or_val : Token | Literal)
      if var_or_val.is_a?(Literal)
        case var_or_val.type
        when :string
          return ValString.new(:string, var_or_val.value.to_s)
        when :number
          return ValNumber.new(:number, var_or_val.value.to_f64)
        when :bool
          return ValBool.new(:bool, var_or_val.value.to_i)
        end
        raise Exception.new("Runtime error: Unknown literal type")
      else
        val = get_var(var_or_val.name)
        if val.nil?
          raise Exception.new("Runtime error: No such variable '" + var_or_val.name + "'.")
        else
          return val
        end
      end
    end

    def run(arguments : Array(Value))
      # Populate named arguments
      arguments.each_with_index do |arg, i|
        @variables[@rout.arguments[i]] = arg
      end

      @rout.commands.each do |command|
        if @terminated
          break
        end
        evaluate(command)
      end
      @variables["_"]
    end

  end

  class Runtime
    property program

    def initialize(program : Program, filename : String)
      @program = program
    end

    def run
      main_runner = RoutRunner.new(@program.main, self)
      main_runner.run([] of Value)
    end
  end
end
