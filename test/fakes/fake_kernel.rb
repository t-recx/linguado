class FakeKernel
  attr_accessor :prints
  attr_accessor :puts_array
  attr_accessor :gets_calls
  attr_accessor :requires

  def initialize
    @prints = []
    @puts_array = []
    @gets_calls = 0
    @requires = []
  end

  def print s
    @prints.push s
  end

  def puts s = ''
    @puts_array.push s
  end

  def gets
    @gets_calls += 1
  end

  def require s
    @requires.push s
  end
end
