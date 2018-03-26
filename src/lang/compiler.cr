module Lang
  class Compiler
    def initialize
    end

    def compile_let(command : Command)
      ret = "let "
      ret += command.arguments[0].getCompiledValue + " = " + command.arguments[1].getCompiledValue + ";"
    end

    def compile_if(command : Command)
      ret = "if (#{command.arguments[0].getCompiledValue}) {"
      ret += "return #{command.arguments[2].getCompiledValue}"
      ret += "}"
    end

    def compile_cmd(command : Command)
      command_name = command.command
      if (command_name == "let")
        return self.compile_let(command)
      end

      if command_name == "if"
        return self.compile_if(command)
      end
      ret = "__taiga_retval__ = " + command_name + "("


      ret += command.arguments.map {|arg|
        if arg.is_a?(Token)
          if arg.name == "_"
            "__taiga_retval__"
          else
            arg.name
          end
        elsif arg.is_a?(Literal)
          arg.getCompiledValue
        end
      }.join(", ")
      ret += ");"
    end

    def compile_rout(routine : Routine)
      if routine.commands.size != 0
        arg_str = routine.arguments.join(", ")
        func_name = routine.name
        ret = "const #{func_name} = (#{arg_str}) => {\nlet __taiga_retval__;\n"
        ret += routine.commands.map {|command| compile_cmd(command)}.join("\n")
        ret += "\nreturn __taiga_retval__;\n};"
      end
    end

    def compile_routs(program : Program)
      ret = program.routines.values.map {|routine| compile_rout(routine)}.join("\n\n")
      if program.routines["main"].commands.size > 0
        ret += "\nmain();"
      end
      ret
    end

    def compile(program : Program)
      js_std_lib = StdLibProvider.new.getStdLibString
      out_code = js_std_lib
      out_code += compile_routs(program)
      puts out_code
    end
  end
end
