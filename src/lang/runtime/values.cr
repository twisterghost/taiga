module Lang
  abstract class Value
    property type : Symbol
    property value : VariableValue

    def initialize(type, value)
      @type = type
      @value = value
    end

    def print
      @value.to_s
    end
  end

  class ValRoutine < Value
    property context : Program

    def initialize(type, value)
      @type = type
      @value = value
      @context = Program.new(Routine.new(""))
    end
  end

  class ValString < Value
    def value
      if @value.is_a?(String)
        return @value
      end
      raise Exception.new("Runtime error: Internal string rep isnt a string")
    end

    def print
      @value.to_s
    end
  end

  class ValNumber < Value
    def value
      val = @value
      if val.is_a?(Number)
        return val.to_f64
      end
      raise Exception.new("Runtime error: Internal number rep isnt a number")
    end
  end

  class ValBool < Value
    def initialize(type : Symbol, value : VariableValue)
      @type = type
      if value.is_a?(Bool)
        if value
          @value = 1
        else
          @value = 0
        end
      else
        @value = value
      end
    end

    def initialize(type : Symbol, value : Bool)
      @type = type
      if value
        @value = 1
      else
        @value = 0
      end
    end

    def value
      if @value == 1
        return true
      else
        return false
      end
    end

    def print
      if @value == 1
        return "true"
      else
        return "false"
      end
    end
  end

  class ValHash < Value
    def initialize(type)
      @type = type
      @value = {} of String => Value
    end

    def initialize(type, value : Hash(String, Value))
      @type = type
      @value = value
    end

    def print
      str = ""
      hash_value = @value
      if hash_value.is_a?(Hash(String, Value))
        hash_value.each do |key, item|
          str += key + ": " + item.print + ", "
        end
      end
      str
    end
  end

  class ValArray < Value
    def initialize(type : Symbol)
      @type = type
      @value = [] of Value
    end

    def initialize(type : Symbol, value : VariableValue)
      @type = type
      @value = value
    end

    def print
      str = "["
      arr_value = @value
      if arr_value.is_a?(Array(Value))
        str += arr_value.map {|val| val.print}.join(", ")
      end
      str + "]"
    end
  end
end
