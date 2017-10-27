module StdLib
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
end
