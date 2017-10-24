module Lang

  class ASTNode
    property type
    property value

    def initialize(type : Symbol, value : String | Float64)
      @type = type
      @value = value
    end
  end

  class AST
    property nodes

    def initialize
      @nodes = [] of ASTNode
    end

    def add_node(node : ASTNode)
      @nodes.push(node)
    end

  end

  class Lexer
    def initialize(content : String, filename : String)
      @content = content
      @filename = filename
      @current_line = 0
      @current_char = 0
    end

    def lex
      ast = AST.new
      line_number = 0
      @content.each_line do |line|
        line = line.strip

        parts = coerce_line_to_parts(line)

        if parts.size > 0
          ast.add_node(ASTNode.new(:command, parts.shift))

          while parts.size > 0
            value = parts.shift
            type = determine_type(value)
            case type
            when :number
              ast.add_node(ASTNode.new(type, value.to_f))
            when :string, :token
              ast.add_node(ASTNode.new(type, value))
            end
          end
        end
        ast.add_node(ASTNode.new(:newline, ""))
        line_number += 1
      end
      ast.add_node(ASTNode.new(:eof, ""))
      ast
    end

    def coerce_line_to_parts(line : String)
      raw = line.split(" ")
      parts = [] of String
      parsing_string = false
      working_part = ""

      while raw.size > 0
        raw_part = raw[0]
        if raw_part[0] == '"'
          parsing_string = true
          working_part += raw.shift
        elsif raw_part[-1] == '"'
          parsing_string = false
          working_part += raw.shift
          parts.push(working_part)
        else
          parts.push(raw.shift)
        end
      end

      if parsing_string
        raise Exception.new("Lexing error: Unterminated string")
      end

      parts
    end

    def determine_type(value : String)
      return :string if value[0] == '"'
      return :number if value.match(/[0-9\.]+/)
      return :token
    end

  end

end
