class FakeSpeaker
  attr_accessor :sentences

  def initialize
    @sentences = []
  end

  def speak sentence, language = nil
    @sentences.push({ sentence: sentence, language: language })
  end
end
