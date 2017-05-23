class FakeDir
  attr_accessor :home
  attr_accessor :globs

  def initialize
    @globs = {}
    @home = '/home/fake'
  end

  def glob s
    @globs[s] || []
  end
end
