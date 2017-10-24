module Lang

  class Literal
    property type
    property value

    def initialize(type : Symbol, value : String | Float64)
      @type = type
      @value = value
    end
  end

  class Variable
    property value

    def initialize(value : String)
      @value = value
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
  end

  class Parser
    def initialize(ast : AST, filename : String)
      @ast = ast
      @commands = [] of Command
      @filename = filename
    end

    def parse
      i = 0
      current_command = Command.new

      while i < @ast.nodes.size
        node = @ast.nodes[i]

        case node.type
        when :command
          current_command.command = node.value.to_s
        when :number, :string
          current_command.add_argument(Literal.new(node.type, node.value))
        when :token
          current_command.add_argument(Variable.new(node.value.to_s))
        when :newline
          @commands.push(current_command)
          current_command = Command.new
        end
        i += 1
      end
      @commands
    end
  end
end
