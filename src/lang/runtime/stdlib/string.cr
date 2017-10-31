module StdLib
  module StringLib
    def self.cat(args : Lang::Arguments)
      str = ""
      args.values.each do |val|
        this_str = require_string(val)
        str += this_str
      end
      Lang::ValString.new(:string, str)
    end

    def self.split(args : Lang::Arguments)
      require_args(args, 2, "split")
      base = require_string(args[0])
      splitter = require_string(args[1])
      split_string = base.split(splitter)
      out_arr = Lang::ValArray.new(:array)
      arr = [] of Lang::Value
      split_string.each do |bit|
        arr.push(Lang::ValString.new(:string, bit))
      end
      out_arr.value = arr
      out_arr
    end

    def self.join(args : Lang::Arguments)
      require_args(args, 2, "join")
      arr = require_array(args[0])
      raw_strings = arr.map do |str|
        str.print
      end
      joiner = require_string(args[1])
      joined_string = raw_strings.join(joiner)
      Lang::ValString.new(:string, joined_string)
    end
  end
end
