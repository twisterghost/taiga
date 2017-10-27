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
end
