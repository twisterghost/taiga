require "file"
require "./lang/**"

module Lang
  file_path = File.expand_path(ARGV[0])
  file_content = File.read(file_path)
  begin
    lexer = Lexer.new(file_content, file_path)
    ast = lexer.lex

    parser = Parser.new(ast, file_path)
    program = parser.parse

    main_runner = RoutRunner.new(program.main, program)
    runner_args = [] of Value

    ARGV[1..-1].each do |arg|
      string_arg = ValString.new(:string, arg)
      runner_args.push(string_arg)
    end
    main_runner.run(runner_args)
  rescue ex
    message = ex.message
    if message.nil?
      puts "Unknown error."
    else
      puts message
    end
  end

end
