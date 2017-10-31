require "./stdlib/*"
include StdLib

module Lang
  class Arguments
    property values : Array(Value)

    def initialize(raw : Array(Literal | Token), context : RoutRunner)
      @values = [] of Value
      raw.each do |arg|
        @values.push(context.value_of(arg))
      end
    end

    def [](index)
      @values[index]
    end
  end

  class RoutRunner
    property variables : Hash(String, Value)
    property rout : Routine
    property context : Program
    property terminated : Bool

    def initialize(rout : Routine, context : Program)
      @rout = rout
      @variables = {} of String => Value
      @variables["_"] = ValBool.new(:bool, 1)
      @context = context
      context.routines.each do |key, rout|
        command_var = ValRoutine.new(:routine, rout)
        command_var.context = context
        @variables[key] = command_var
      end
      @lastif = false
      @terminated = false
    end

    def get_var(name : String)
      if @variables.has_key?(name)
        return @variables[name]
      end

      if @context.routines.has_key?(name)
        rout = ValRoutine.new(:routine, @context.routines[name])
        rout.context = @context
        return rout
      end

      return nil
    end

    def evaluate_dynamic(parts : Array(Literal | Token))
      if parts.size == 0
        raise Exception.new("Runtime error: Cannot execute nothing")
      end

      potential_command = parts[0]
      if potential_command.is_a?(Token)
        command = Command.new(potential_command.name)
        if parts.size > 1
          command.arguments = parts[1..-1]
        end

        evaluate(command)
      elsif potential_command.is_a?(Literal)
        save_res(value_of(potential_command))
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
      if var_exists(run_command)
        possible_command = get_var(run_command)
        if possible_command.nil?
          raise Exception.new("Runtime error: Cannot run nonexistent routine")
        elsif possible_command.is_a?(ValRoutine)
          command_value = possible_command.value
          command_context = possible_command.context
          if command_value.is_a?(Routine) && command_context.is_a?(Program)
            runner = RoutRunner.new(command_value, command_context)
            save_res(runner.run(arguments.values))
            return
          else
            raise Exception.new("Runtime error: Invalid command value")
          end
        else
          raise Exception.new("Runtime error: Cannot run non-routine")
        end
      end

      # If there is a dot, run from that import context
      if !run_command.index('.').nil?
        parts = run_command.split('.')
        if parts.size > 2
          raise Exception.new("Runtime error: Invalid import access")
        end
        import_name = parts[0]
        import_rout = parts[1]
        if @context.imports.has_key?(import_name)
          if @context.imports[import_name].routines.has_key?(import_rout)
            subrout = @context.imports[import_name].routines[import_rout]
            runner = RoutRunner.new(subrout, @context.imports[import_name])
            save_res(runner.run(arguments.values))
            return
          else
            raise Exception.new("Runtime error: No such rout '" + import_rout + "' on '" + import_name)
          end
        else
          raise Exception.new("Runtime error: No such import '" + import_name + "'")
        end
      end

      save_res(StdLib.resolve(run_command, arguments))

    end

    def save_res(res : Value)
      @variables["_"] = res
    end

    def var_exists(name : String)
      @variables.has_key?(name)
    end

    def value_of(var_or_val : Token | Literal)
      val = value_of_dangerous(var_or_val)
      if val.nil?
        if var_or_val.is_a?(Token)
          raise Exception.new("Runtime error: No such variable '" + var_or_val.name + "'.")
        else
          raise Exception.new("Runtime error: No such value")
        end
      else
        return val
      end
    end

    def value_of_dangerous(var_or_val : Token | Literal)
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
        return get_var(var_or_val.name)
      end
    end

    def run(arguments : Array(Value))
      # Populate named arguments
      arguments.each_with_index do |arg, i|
        if i < @rout.arguments.size
          @variables[@rout.arguments[i]] = arg
        end
      end

      top_args = ValArray.new(:array, arguments)
      @variables["ARGV"] = top_args

      @rout.commands.each do |command|
        if @terminated
          break
        end
        begin
          evaluate(command)
        rescue err
          puts err.message
          puts "at " + command.inspect
          raise Exception.new("Runtime error.")
        end
      end
      @variables["_"]
    end

  end
end
