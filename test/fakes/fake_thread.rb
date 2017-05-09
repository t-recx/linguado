class FakeThread
  def initialize &block
    block.call
  end
end
