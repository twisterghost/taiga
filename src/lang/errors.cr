module Lang
  class RuntimeError < Exception
    def initialize(message : String)
      @message = "Runtime error: " + message
    end
  end
end
