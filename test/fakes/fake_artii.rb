class FakeArtii
  attr_accessor :asciifies

  def initialize
    @asciifies = []
  end

  def asciify sentence
    @asciifies.push sentence

    return sentence
  end
end
