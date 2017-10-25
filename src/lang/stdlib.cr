module StdLib

  def self.resolve(command : String, args : Lang::Arguments)
    case command
    when "print"
      return self.print(args)
    when "add"
      return Math.add(args)
    end
    raise Exception.new("Runtime error: No such command '" + command + "'.");
  end

  def self.print(args : Lang::Arguments)
    str = ""
    args.values.each do |arg|
      str += arg.value.to_s
    end
    puts str
    return Lang::ValBool.new(:bool, 1)
  end

  module Math
    def self.add(args : Lang::Arguments)
      sum = 0.0
      args.values.each do |arg|
        if arg.is_a?(Lang::ValNumber)
          sum += arg.value
        else
          raise Exception.new("Runtime error: Cannot add non-numbers")
        end
      end
      return Lang::ValNumber.new(:number, sum)
    end
  end
end
