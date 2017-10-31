module StdLib
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
      args[0].value = arr
      popped
    end

    def self.shift(args : Lang::Arguments)
      require_args(args, 1, "arrShift")
      arr = require_array(args[0])
      popped = arr.shift
      args[0].value = arr
      popped
    end
  end
end
