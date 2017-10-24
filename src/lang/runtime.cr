module Lang
  class Runtime
    def initialize(program : Program, filename : String)
      @program = program
    end

    def run
      puts @program.inspect
    end
  end
end
