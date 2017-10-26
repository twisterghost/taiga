require "file"
require "./lang/*"

module Lang
  file_path = File.expand_path(ARGV[0])
  file_content = File.read(file_path)
  begin
    lexer = Lexer.new(file_content, file_path)
    ast = lexer.lex

    parser = Parser.new(ast, file_path)
    program = parser.parse

    runtime = Runtime.new(program, file_path)
    runtime.run
  rescue ex
    message = ex.message
    if message.nil?
      puts "Unknown error."
    else
      puts message
    end
  end

end
