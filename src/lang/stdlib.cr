module StdLib

  def min_args(args : Lang::Arguments, min_count, name)
    if args.values.size < min_count
      raise Exception.new(name + " requires at minimum " + min_count.to_s + " arguments.")
    end
  end

  def require_string(value : Lang::Value)
    true_value = value.value
    if value.is_a?(Lang::ValString) && true_value.is_a?(String)
      return true_value
    else
      raise Exception.new("Argument mismatch: Expected string")
    end
  end

  def require_number(value : Lang::Value)
    true_value = value.value
    if value.is_a?(Lang::ValNumber) && true_value.is_a?(Float64)
      return true_value
    else
      raise Exception.new("Argument mismatch: Expected number.")
    end
  end

  def require_bool(value : Lang::Value)
    true_value = value.value
    if value.is_a?(Lang::ValBool) && true_value.is_a?(Boolean)
      return true_value
    else
      raise Exception.new("Argument mismatch: Expected bool.")
    end
  end

  def require_hash(value : Lang::Value)
    true_value = value.value
    if value.is_a?(Lang::ValHash) && true_value.is_a?(Hash(String, Lang::Value))
      return true_value
    else
      raise Exception.new("Argument mismatch: Expected hash.")
    end
  end

  def require_array(value : Lang::Value)
    true_value = value.value
    if value.is_a?(Lang::ValArray) && true_value.is_a?(Array(Lang::Value))
      return true_value
    else
      raise Exception.new("Argument mismatch: Expected array.")
    end
  end

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
    when "hash"
      return HashLib.create()
    when "hashSet"
      return HashLib.set(args)
    when "hashGet"
      return HashLib.get(args)
    when "hashHas"
      return HashLib.has(args)
    when "arr"
      return ArrayLib.create(args)
    when "arrGet"
      return ArrayLib.get(args)
    when "arrSize"
      return ArrayLib.size(args)
    end
    raise Exception.new("Runtime error: No such command '" + command + "'.");
  end

  def self.print(args : Lang::Arguments)
    str = ""
    args.values.each do |arg|
      str += arg.print
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
      sum = 0.0.to_f64
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

  module HashLib
    def self.create
      return Lang::ValHash.new(:hash)
    end

    def self.set(args : Lang::Arguments)
      if args.values.size < 3
        raise Exception.new("Runtime error: hashSet must have 3 arguments")
      end

      hash = args.values[0]
      key = args.values[1]
      val = args.values[2]
      if hash.is_a?(Lang::ValHash) && key.is_a?(Lang::ValString) && val.is_a?(Lang::Value)
        raw_hash = hash.value
        raw_key = key.value
        if raw_hash.is_a?(Hash(String, Lang::Value)) && raw_key.is_a?(String)
          raw_hash[raw_key] = val
          return hash
        end
        raise Exception.new("Runtime error: Incorrect argument values for hash.set")
      end
      raise Exception.new("Runtime error: Incorrect arguments for hash.set")
    end

    def self.get(args : Lang::Arguments)
      if args.values.size < 2
        raise Exception.new("Runtime error: hashGet must have 2 arguments")
      end

      hash = args.values[0]
      key = args.values[1]
      if hash.is_a?(Lang::ValHash) && key.is_a?(Lang::ValString)
        raw_hash = hash.value
        raw_key = key.value
        if raw_hash.is_a?(Hash(String, Lang::Value)) && raw_key.is_a?(String)
          if raw_hash.has_key?(raw_key)
            return raw_hash[raw_key]
          else
            raise Exception.new("Runtime error: No such key '" + raw_key + "' in hash")
          end
        end
        raise Exception.new("Runtime error: Incorrect argument values for hash.get")
      end
      raise Exception.new("Runtime error: Incorrect arguments for hash.get")
    end

    def self.has(args : Lang::Arguments)
      if args.values.size < 2
        raise Exception.new("Runtime error: hashHas must have 2 arguments")
      end

      hash = args.values[0]
      key = args.values[1]
      if hash.is_a?(Lang::ValHash) && key.is_a?(Lang::ValString)
        raw_hash = hash.value
        raw_key = key.value
        if raw_hash.is_a?(Hash(String, Lang::Value)) && raw_key.is_a?(String)
          if raw_hash.has_key?(raw_key)
            return Lang::ValBool.new(:bool, 1)
          else
            return Lang::ValBool.new(:bool, 0)
          end
        end
        raise Exception.new("Runtime error: Incorrect argument values for hash.get")
      end
      raise Exception.new("Runtime error: Incorrect arguments for hash.get")
    end
  end

  module ArrayLib
    def self.create(args : Lang::Arguments)
      arr = Lang::ValArray.new(:array)
      arr.value = args.values
      arr
    end

    def self.size(args : Lang::Arguments)
      min_args(args, 1, "arrSize")
      arr = require_array(args.values[0])
      return Lang::ValNumber.new(:number, arr.size)
    end

    def self.get(args : Lang::Arguments)
      if args.values.size < 2
        raise Exception.new("Runtime error: arrGet must have 2 arguments")
      end
      arr = args.values[0]
      index = args.values[1]
      if arr.is_a?(Lang::ValArray) && index.is_a?(Lang::ValNumber)
        arr_val = arr.value
        index_val = index.value
        if arr_val.is_a?(Array) && arr_val.is_a?(Float64)
          return arr_val[index_val]
        else
          raise Exception.new("Runtime panic: Internal array value or number value is incorrect")
        end
      else
        raise Exception.new("Runtime error: arrSize must take an array")
      end
    end
  end
end
