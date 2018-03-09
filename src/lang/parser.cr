require "file"

module Lang

  class Literal
    property type
    property value : PrimitiveValue

    def initialize(type : Symbol, value : PrimitiveValue)
      @type = type
      @value = value

      if @type == :string
        @value = @value.to_s[1...-1]
      end
    end

    def inspect
      @type.to_s + ":" + @value.to_s
    end

    def getCompiledValue
      @value.to_s
    end
  end

  class Token
    property name

    def initialize(name : String)
      @name = name
    end

    def inspect
      "token:" + @name
    end

    def getCompiledValue
      @name
    end
  end

  class Program
    property routines : Hash(String, Routine)
    property main : Routine
    property imports : Hash(String, Program)

    def initialize(main : Routine)
      @main = main
      @routines = {"main" => main}
      @imports = {} of String => Program
    end

    def inspect
      ret = @routines.values.map {|routine| routine.inspect}.join("\n\n")
      ret
    end

    def compile
      @routines.values.map {|routine| routine.compile}.join("\n\n")
    end
  end

  class Routine
    property commands : Array(Command)
    property arguments : Array(String)
    property name : String

    def initialize(name : String)
      @name = name
      @commands = [] of Command
      @arguments = [] of String
    end

    def inspect
      ret = "ROUT " + @name + ": " + @arguments.join(", ") + "\n"
      ret += @commands.map {|command| "  " + command.inspect}.join("\n")
      ret
    end

    def compile
      if @commands.size != 0
        arg_str = @arguments.join(", ")
        func_name = @name
        ret = "const #{func_name} = (#{arg_str}) => {\nlet __taiga_retval__;\n"
        ret += @commands.map {|command| command.compile}.join("\n")
        ret += "\nreturn __taiga_retval__;\n};"
      end
    end

    def to_s
      inspect
    end
  end

  class Command
    property command : String
    property arguments : Array(Literal | Token)

    def initialize(command : String)
      @command = command
      @arguments = [] of (Literal | Token)
    end

    def initialize()
      @command = ""
      @arguments = [] of (Literal | Token)
    end

    def add_argument(node : Literal | Token)
      @arguments.push(node)
    end

    def inspect
      ret = @command + " "
      ret += @arguments.map {|arg| arg.inspect}.join(" ")
      ret
    end

    def compile_let
      ret = "let "
      ret += @arguments[0].getCompiledValue + " = " + @arguments[1].getCompiledValue + ";"
    end

    def compile
      command_name = @command
      if (command_name == "let")
        return self.compile_let
      end

      if command_name == "if"
        command_name = "taiga_if"
      end
      ret = "__taiga_retval__ = " + command_name + "("


      ret += @arguments.map {|arg|
        if arg.is_a?(Token)
          if arg.name == "_"
            "__taiga_retval__"
          else
            arg.name
          end
        elsif arg.is_a?(Literal)
          arg.value
        end
      }.join(", ")
      ret += ");"
    end
  end

  class Parser
    def initialize(ast : AST, filename : String)
      @ast = ast
      @filename = filename
      @main = Routine.new("main")
      @program = Program.new(@main)
    end

    def resolve_path(import_path : String)
      base_path = File.dirname(@filename)
      File.expand_path(import_path, base_path)
    end

    def handle_import(command : Command)
      import_filename = command.arguments[0]
      import_token = command.arguments[1]
      if import_filename.is_a?(Literal) && import_token.is_a?(Token)
        import_path = resolve_path(import_filename.value.to_s)
        content = File.read(import_path)

        # Lex, parse and save import
        import_lexer = Lexer.new(content, import_path)
        import_ast = import_lexer.lex
        import_parser = Parser.new(import_ast, import_path)
        imported_program = import_parser.parse
        @program.imports[import_token.name.to_s] = imported_program
      else
        raise Exception.new("Parsing error: Import must be string and token")
      end
    end

    def parse
      i = 0
      current_command = Command.new
      current_routine = @main
      is_new_routine = false
      is_import = false

      while i < @ast.nodes.size
        node = @ast.nodes[i]

        case node.type
        when :command
          case node.value.to_s
          when "rout"
            if current_routine != @main
              raise Exception.new("Paring error: Unexpected routine definition")
            end
            i += 1
            next_node = @ast.nodes[i]
            if next_node.type != :token
              raise Exception.new("Parsing error: Unexpected rout name")
            end

            routine_name = next_node.value.to_s
            current_routine = Routine.new(routine_name)
            is_new_routine = true
          when "endrout"
            @program.routines[current_routine.name] = current_routine
            current_routine = @main
          when "import"
            is_import = true
          else
            current_command.command = node.value.to_s
          end
        when :number, :string, :bool
          if is_new_routine
            raise Exception.new("Parsing error: Unexpected literal")
          end
          current_command.add_argument(Literal.new(node.type, node.value))
        when :token
          if is_new_routine
            current_routine.arguments.push(node.value.to_s)
          else
            current_command.add_argument(Token.new(node.value.to_s))
          end
        when :newline, :eof
          if is_new_routine
            is_new_routine = false
          elsif is_import
            handle_import(current_command)
            is_import = false
          else
            if current_command.command.size != 0
              current_routine.commands.push(current_command)
            end
          end
            current_command = Command.new
        end
        i += 1
      end
      @program
    end
  end
end
