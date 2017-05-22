class FakeRunner
  attr_accessor :asked
  attr_accessor :questions_asked
  attr_accessor :correct_answers

  def initialize
    @asked = []
    @questions_asked = 0
    @correct_answers = 0
  end

  def ask questions, delta_answers_required = 20
    @asked.push questions
    return [@questions_asked, @correct_answers]
  end
end
