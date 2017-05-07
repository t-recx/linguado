class FakePrompt
  attr_accessor :questions
  attr_accessor :okays
  attr_accessor :errors
  attr_accessor :answers
  attr_accessor :multi_selections

  def initialize
    @questions = []
    @okays = []
    @errors = []
    @answers = {}
    @multi_selections = []
  end

  def ask sentence
    questions.push sentence

    return @answers[sentence]
  end

  def ok sentence
    okays.push sentence
  end

  def error sentence
    errors.push sentence
  end

  def multi_select title, choices, options = nil
    multi_selections.push({ title: title, choices: choices, options: options })

    return @answers[title]
  end

  def setup_answer sentence, response
    @answers[sentence] = response
  end
end
