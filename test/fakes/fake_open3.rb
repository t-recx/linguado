class FakeOpen3
  attr_accessor :calls
  attr_accessor :wait_threads
  attr_accessor :default_wait_thread

  def initialize
    @calls = []  
    @default_wait_thread = FakeWaitThread.new
    @wait_threads = {}
  end

  def popen3(*cmd, &block)
    @calls.push cmd
    
    return nil, nil, nil, @wait_threads[cmd] || @default_wait_thread
  end
end

class FakeWaitThread
  attr_accessor :value

  def initialize(success = true)
    @value = FakeProcessStatus.new(success)
  end
end

class FakeProcessStatus
  attr_accessor :success
  alias_method :success?, :success

  def initialize(s)
    @success = s
  end
end
