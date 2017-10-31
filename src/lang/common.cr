module Lang
  alias VariableValue = String | Float64 | Int32 | Hash(String, Value) | Array(Value) | Routine
  alias PrimitiveValue = String | Float64 | Int32
end
