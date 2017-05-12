class FakeKernel
  attr_accessor :prints
  attr_accessor :puts_array

  def initialize
    @prints = []
    @puts_array = []
  end

  def print s
    @prints.push s
  end

  def puts s
    @puts_array.push s
  end
end
