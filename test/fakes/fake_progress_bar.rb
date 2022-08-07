class FakeProgressBar
  attr_accessor :current
  attr_accessor :format
  attr_accessor :options
  attr_accessor :started
  attr_accessor :advance_stack

  def initialize format, options = { }
    @format = format
    @options = options
    @current = 0
    @started = false
    @advance_stack = []
  end

  def start
    @started = true
  end

  def advance number
    @current += number
    @advance_stack.push number
  end
end
