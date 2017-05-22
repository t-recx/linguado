class FakeLesson
  attr_accessor :questions
  attr_accessor :name

  def initialize questions, name: nil
    @questions = questions || []
    @name = name
  end
end
