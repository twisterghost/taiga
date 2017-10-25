require "./stdlib"
include StdLib

module Lang

  class Variable
  end

  class RoutRunner
    property variables : Hash(String, Literal)
    property rout : Routine
    property context : Runtime

    def initialize(rout : Routine, context : Runtime)
      @rout = rout
      @variables = {} of String => Literal
      @context = context
    end

    def evaluate(command : Command)
      run_command = command.command
      arguments = command.arguments

      case run_command
      when "print"
        StdLib.print(value_of(arguments[0]))
        return Literal.new(:bool, true)
      when "let"
        first_arg = arguments[0]
        if first_arg.is_a?(Token)
          variable_name = first_arg.name
          value = value_of(arguments[1])
          @variables[variable_name] = value
          return value
        else
          raise Exception.new("Runtime error: Invalid variable name")
        end
      else
        # Check if the context has this command as a routine
        if @context.program.routines.has_key?(run_command)
          subrout = @context.program.routines[run_command]
          runner = RoutRunner.new(subrout, @context)
          res = runner.run
          @variables["_"] = res
          return res
        else
          raise Exception.new("Runtime error: No such routine '" + run_command + "'.")
        end

      end
    end

    def value_of(var_or_val : Token | Literal)
      if var_or_val.is_a?(Literal)
        return var_or_val
      else
        if @variables.has_key?(var_or_val.name)
          return @variables[var_or_val.name]
        else
          raise Exception.new("Runtime error: No such variable '" + var_or_val.name + "'.")
        end
      end
    end

    def run
      res : Literal = Literal.new(:bool, true)
      @rout.commands.each do |command|
        res = evaluate(command)
      end
      res
    end

  end

  class Runtime
    property program

    def initialize(program : Program, filename : String)
      @program = program
    end

    def run
      main_runner = RoutRunner.new(@program.main, self)
      main_runner.run
    end
  end
end
