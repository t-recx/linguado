module Linguado
  class Lesson
    attr_accessor :prompt
    attr_accessor :speaker
    attr_accessor :questions

    def initialize(prompt = nil, speaker = nil)
      @prompt = prompt || TTY::Prompt.new 
      @speaker = speaker || Speaker.new
      @questions = []
    end
    
    def question &block
      @questions.push block
    end

    def run
      @questions.shuffle.map(&:call)
    end

    def translate sentence, *correct_answers
      response = @prompt.ask sentence

      return correct! if correct? response, *correct_answers

      error correct_answers.first
    end

    def select title, correct = [], incorrect = []
      response = @prompt.multi_select title, correct + incorrect, enum: ')'

      return correct! if response and correct.all? { |possibility| response.any? { |answer| correct? answer, possibility } } and incorrect.none? { |wrong| response.any? { |answer| answer == wrong } }
        
      error correct
    end

    def write sentence
      @speaker.speak sentence

      response = @prompt.ask "Type what you hear"

      return correct! if correct? response, sentence

      error sentence
    end

    def correct? answer, *possibilities
      answer and possibilities.any? { |possibility| answer.downcase == possibility.downcase }
    end

    def correct!
      @prompt.ok "Correct!"
    end

    def error *possible_solutions
      header = "Correct solution"

      header += "s" if possible_solutions.length > 1

      @prompt.error "#{header}:\n#{possible_solutions.join(", ")}"
    end
  end
end
