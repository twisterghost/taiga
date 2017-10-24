module Lang

  class Literal
    property type
    property value

    def initialize(type : Symbol, value : String | Float64)
      @type = type
      @value = value
    end

    def inspect
      @type.to_s + ":" + @value.to_s
    end
  end

  class Variable
    property value

    def initialize(value : String)
      @value = value
    end

    def inspect
      "var:" + @value
    end
  end

  class Program
    property routines : Hash(String, Routine)
    property main : Routine

    def initialize(main : Routine)
      @main = main
      @routines = {"main" => main}
    end

    def inspect
      ret = @routines.values.map {|routine| routine.inspect}.join("\n\n")
      ret
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
  end

  class Command
    property command : String
    property arguments : Array(Literal | Variable)

    def initialize(command : String)
      @command = command
      @arguments = [] of (Literal | Variable)
    end

    def initialize()
      @command = ""
      @arguments = [] of (Literal | Variable)
    end

    def add_argument(node : Variable | Literal)
      @arguments.push(node)
    end

    def inspect
      ret = @command + " "
      ret += @arguments.map {|arg| arg.inspect}.join(" ")
      ret
    end
  end

  class Parser
    def initialize(ast : AST, filename : String)
      @ast = ast
      @filename = filename
    end

    def parse
      main = Routine.new("main")
      program = Program.new(main)
      i = 0
      current_command = Command.new
      current_routine = main
      is_new_routine = false

      while i < @ast.nodes.size
        node = @ast.nodes[i]

        case node.type
        when :command
          case node.value.to_s
          when "rout"
            if current_routine != main
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
            program.routines[current_routine.name] = current_routine
            current_routine = main
          else
            current_command.command = node.value.to_s
          end
        when :number, :string
          if is_new_routine
            raise Exception.new("Parsing error: Unexpected literal")
          end
          current_command.add_argument(Literal.new(node.type, node.value))
        when :token
          if is_new_routine
            current_routine.arguments.push(node.value.to_s)
          else
            current_command.add_argument(Variable.new(node.value.to_s))
          end
        when :newline, :eof
          if is_new_routine
            is_new_routine = false
          else
            if current_command.command.size != 0
              current_routine.commands.push(current_command)
            end
          end
            current_command = Command.new
        end
        i += 1
      end
      program
    end
  end
end
