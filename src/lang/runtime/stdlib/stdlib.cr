module StdLib
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

end
