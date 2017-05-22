class FakePrompt
  attr_accessor :questions
  attr_accessor :okays
  attr_accessor :errors
  attr_accessor :says
  attr_accessor :answers
  attr_accessor :multi_selections
  attr_accessor :selections

  def initialize
    @questions = []
    @okays = []
    @errors = []
    @says = []
    @answers = {}
    @multi_selections = []
    @selections = []
  end

  def say sentence
    says.push sentence
  end

  def ask sentence
    questions.push sentence

    return @answers[sentence].shift if @answers[sentence]
  end

  def ok sentence
    okays.push sentence
  end

  def error sentence
    errors.push sentence
  end

  def multi_select title, choices, options = nil
    multi_selections.push({ title: title, choices: choices, options: options })

    return @answers[title].shift if @answers[title]
  end

  def select title, choices, options = nil
    selections.push({ title: title, choices: choices, options: options })

    return @answers[title].shift if @answers[title]
  end

  def setup_answer sentence, response
    @answers[sentence] = [] unless @answers[sentence]
    @answers[sentence].push response
  end
end
