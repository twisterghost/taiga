module Lang
  class Runtime
    def initialize(commands : Array(Command), filename : String)
      @commands = commands
    end

    def run
      @commands.each do |command|
        if command.command == "print"
          puts command.arguments[0].value
        end
      end
    end
  end
end
