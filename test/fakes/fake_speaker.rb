class FakeSpeaker
  attr_accessor :sentences

  def initialize
    @sentences = []
  end

  def speak sentence
    @sentences.push sentence
  end
end
