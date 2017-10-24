module StdLib
  def self.print(value : Lang::Literal)
    puts value.value.to_s
  end
end
