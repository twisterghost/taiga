module StdLib

  def self.resolve(command : String, args : Lang::Arguments)
    case command
    when "print"
      return self.print(args)
    when "add"
      return Math.add(args)
    when "sub"
      return Math.sub(args)
    when "eq"
      return self.eq(args)
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

  def self.eq(args : Lang::Arguments)
    is_eq = true
    args.values.each_with_index do |arg, i|
      if i < args.values.size - 1
        a = args.values[i]
        b = args.values[i + 1]
        is_eq = is_eq && a.type == b.type && a.value.to_s == b.value.to_s
      end
    end
    return Lang::ValBool.new(:bool, is_eq)
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

    def self.sub(args : Lang::Arguments)
      sum = 0.0
      if args.values.size == 0
        raise Exception.new("Runtime error: Cannot sub nothing")
      end

      first_val = args.values[0]
      if first_val.is_a?(Lang::ValNumber)
        sum = first_val.value
      else
        raise Exception.new("Runtime error: Cannot sub a non-number")
      end
      args.values[1..-1].each do |arg|
        if arg.is_a?(Lang::ValNumber)
          sum -= arg.value
        else
          raise Exception.new("Runtime error: Cannot sub a non-number")
        end
      end
      return Lang::ValNumber.new(:number, sum)
    end
  end
end
