module StdLib
  module Math
    def self.add(args : Lang::Arguments)
      sum = 0.0.to_f64
      args.values.each do |arg|
        val = require_number(arg)
        sum += val
      end
      return Lang::ValNumber.new(:number, sum)
    end

    def self.sub(args : Lang::Arguments)
      require_args(args, 2, "sub")
      sum = require_number(args[0])
      args.values[1..-1].each do |arg|
        val = require_number(arg)
        sum -= val
      end
      return Lang::ValNumber.new(:number, sum)
    end
  end
end
