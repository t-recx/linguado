class FakeLesson
  attr_accessor :questions

  def initialize questions
    @questions = questions || []
  end
end
