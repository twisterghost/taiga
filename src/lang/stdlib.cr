module StdLib
  def self.print(value : Lang::Value | Nil)
    if value.nil?
      puts
    else
      puts value.value.to_s
    end
    return Lang::ValBool.new(:bool, 1)
  end

  module Math
    def self.add(valueA : Lang::Value, valueB : Lang::Value)
      if valueA.is_a?(Lang::ValNumber) && valueB.is_a?(Lang::ValNumber)
        res = valueA.value + valueB.value
        return Lang::ValNumber.new(:number, res)
      end
      raise Exception.new("Runtime error: Cannot add non-numbers")
    end
  end
end
