module Lang
  class Compiler
    def initialize
    end

    def compile(program : Program)
      js_std_lib = StdLibProvider.new.getStdLibString
      puts js_std_lib;
      puts program.compile
    end
  end
end
