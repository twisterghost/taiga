module StdLib

  def require_args(args : Lang::Arguments, min_count, name)
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

  macro api(command_api)
    case command
    {% for cmd, func in command_api %}
    when "{{cmd.id}}"
      return {{func.id}}(args)
    {% end %}
    end
  end

  def self.resolve(command : String, args : Lang::Arguments)
    api({
      "print": print,
      "eq": eq,
      "add": Math.add,
      "sub": Math.sub,
      "hash": HashLib.create,
      "hashSet": HashLib.set,
      "hashGet": HashLib.get,
      "hashHas": HashLib.has,
      "arr": ArrayLib.create,
      "arrGet": ArrayLib.get,
      "arrSize": ArrayLib.size,
      "arrPush": ArrayLib.push,
      "arrPop": ArrayLib.pop
    })
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

  module HashLib
    def self.create(args : Lang::Arguments)
      return Lang::ValHash.new(:hash)
    end

    def self.set(args : Lang::Arguments)
      require_args(args, 3, "hashSet")
      hash = require_hash(args[0])
      key = require_string(args[1])
      val = args[2]
      hash[key] = val
      return Lang::ValHash.new(:hash, hash)
    end

    def self.get(args : Lang::Arguments)
      require_args(args, 2, "hashGet")
      hash = require_hash(args.values[0])
      key = require_string(args.values[1])
      return hash[key]
    end

    def self.has(args : Lang::Arguments)
      require_args(args, 2, "hashHas")
      hash = require_hash(args.values[0])
      key = require_string(args.values[1])
      if hash.has_key?(key)
        return Lang::ValBool.new(:bool, 1)
      else
        return Lang::ValBool.new(:bool, 0)
      end
    end
  end

  module ArrayLib
    def self.create(args : Lang::Arguments)
      arr = Lang::ValArray.new(:array)
      arr.value = args.values
      arr
    end

    def self.size(args : Lang::Arguments)
      require_args(args, 1, "arrSize")
      arr = require_array(args.values[0])
      return Lang::ValNumber.new(:number, arr.size)
    end

    def self.get(args : Lang::Arguments)
      require_args(args, 2, "arrGet")
      arr = require_array(args[0])
      index = require_number(args[1]).to_i
      arr[index]
    end

    def self.set(args : Lang::Arguments)
      require_args(args, 3, "arrSet")
      arr = require_array(args[0])
      index = require_number(args[1]).to_i
      val = args[2]
      arr[index] = val
      Lang::ValArray.new(:array, arr)
    end

    def self.push(args : Lang::Arguments)
      require_args(args, 2, "arrPush")
      arr = require_array(args[0])
      val = args[1]
      arr.push(val)
      Lang::ValArray.new(:array, arr)
    end

    def self.pop(args : Lang::Arguments)
      require_args(args, 1, "arrPop")
      arr = require_array(args[0])
      popped = arr.pop
      popped
    end
  end
end
