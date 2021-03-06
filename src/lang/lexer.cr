module Lang

  class ASTNode
    property type
    property value

    def initialize(type : Symbol, value : String | Float64 | Int32)
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
        parts = coerce_line_to_parts(line, line_number)

        if parts.size > 0
          ast.add_node(ASTNode.new(:command, parts.shift))

          while parts.size > 0
            value = parts.shift
            type = Lexer.determine_type(value)
            case type
            when :number
              ast.add_node(ASTNode.new(type, value.to_f))
            when :string, :token
              ast.add_node(ASTNode.new(type, value))
            when :bool
              if value == "true"
                ast.add_node(ASTNode.new(type, 1))
              else
                ast.add_node(ASTNode.new(type, 0))
              end
            end
          end
        end
        ast.add_node(ASTNode.new(:newline, ""))
        line_number += 1
      end
      ast.add_node(ASTNode.new(:eof, ""))
      ast
    end

    def coerce_line_to_parts(line : String, line_number : Int)
      if line.size == 0
        return [] of String
      end

      if line[0] == '#'
        return [] of String
      end
      raw = line.split(" ")
      parts = [] of String
      parsing_string = false
      working_part = ""

      while raw.size > 0
        raw_part = raw[0]
        if raw_part[0] == '"' && !parsing_string
          if raw_part[-1] == '"' && raw_part.size > 1
            parts.push(raw.shift)
          else
            parsing_string = true
            working_part += raw.shift + " "
          end
        elsif raw_part[-1] == '"'
          parsing_string = false
          working_part += raw.shift
          parts.push(working_part)
        elsif parsing_string
          working_part += raw.shift + " "
        else
          parts.push(raw.shift)
        end
      end

      if parsing_string
        raise Exception.new("Lexing error: Unterminated string on line " + line_number.to_s)
      end

      parts
    end

    def self.determine_type(value : String)
      return :string if value[0] == '"'
      return :number if value.match(/^[0-9\.]+$/)
      return :bool if value == "true" || value == "false"
      return :token
    end

  end

end
