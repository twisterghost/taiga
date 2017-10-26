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
    when "hash"
      return HashLib.create()
    when "hashSet"
      return HashLib.set(args)
    when "hashGet"
      return HashLib.get(args)
    when "hashHas"
      return HashLib.has(args)
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
end
