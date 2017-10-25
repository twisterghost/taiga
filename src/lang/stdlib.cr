module StdLib
  def self.print(value : Lang::Value | Nil)
    if value.nil?
      puts
    else
      puts value.value.to_s
    end
  end
end
