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
  end
end
