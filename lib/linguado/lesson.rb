require 'tty-prompt'
require 'pastel'

module Linguado
  class Lesson
    attr_accessor :prompt
    attr_accessor :speaker
    attr_accessor :pastel
    attr_accessor :thread
    attr_accessor :questions
    attr_accessor :language
    attr_accessor :word_policies

    def initialize(prompt = nil, speaker = nil, pastel = nil, thread = nil, language: 'en-US', word_policies: [])
      @language = language
      @word_policies = word_policies
      @prompt = prompt || TTY::Prompt.new 
      @speaker = speaker || Speaker.new
      @pastel = pastel || Pastel.new
      @thread = thread || Thread
      @questions = []
    end

    def question &block
      @questions.push block
    end

    def translate sentence, *correct_answers
      @prompt.say 'Translate this text'
      @prompt.say sentence

      response = @prompt.ask '>'

      correct? response, *correct_answers
    end

    def all_selected answers, correct
      return false unless answers

      correct.all? { |possibility| answers.any? { |answer| answer == possibility } } 
    end

    def none_selected answers, incorrect
      return true unless answers

      incorrect.none? { |wrong| answers.any? { |answer| answer == wrong } }
    end

    def select title, correct = [], incorrect = []
      @prompt.say "Select all correct translations"
      @prompt.say title

      answers = @prompt.multi_select '>', correct + incorrect, enum: ')'

      return correct! if all_selected(answers, correct) and none_selected(answers, incorrect)

      error correct
    end

    def choose title, correct, incorrect
      @prompt.say "Choose the correct option"
      @prompt.say title

      answer = @prompt.select '>', [correct] + incorrect, enum: ')' 

      return correct! if exact_match answer, correct

      error correct
    end

    def write sentence
      @prompt.say "Type what you hear"

      @thread.new { @speaker.speak sentence, language }

      answer = @prompt.ask '>'

      correct? answer, sentence
    end

    def exact_match answer, *possibilities
      return false unless answer

      possibilities.any? { |possibility| answer.downcase == possibility.downcase }
    end

    def correct? answer, *possibilities
      return false unless answer

      answer = answer.downcase

      return correct! if exact_match answer, *possibilities

      if word_policies and word_policies.count > 0 then
        tokens_answer = answer.split

        possibilities.each do |possibility|
          corrected_answer = ""
          used_wrong_words = false
          passed_policies = true
          tokens_possibility = possibility.split 

          tokens_answer.each_with_index do |token, i|
            token_possibility = tokens_possibility[i]

            unless token_possibility
              passed_policies = false
              break
            end

            word_passed_policies = word_policies.all? { |policy| policy.passes? token, token_possibility }

            passed_policies = false if not word_passed_policies

            unless word_passed_policies
              used_wrong_words = true
              corrected_answer += "#{@pastel.underline(token_possibility)} "
            else
              typo = word_policies.any? { |policy| policy.typo? token, tokens_possibility[i] }

              if typo then
                corrected_answer += "#{@pastel.underline(token_possibility)} "
              else
                corrected_answer += "#{token_possibility} "
              end
            end
          end

          corrected_answer.strip!
          
          return almost_correct!(corrected_answer) if passed_policies 
          
          return used_wrong_word(corrected_answer) if used_wrong_words 
        end
      end

      error possibilities.first
    end

    def correct! 
      @prompt.ok "Correct!"

      return true
    end

    def colorize sentence
      sentence.split.map { |x| yield(x) }.join(' ')
    end

    def almost_correct! corrected_answer
      @prompt.ok "Almost Correct!"
      @prompt.ok colorize(corrected_answer) { |x| @pastel.green x }

      return true
    end

    def error *possible_solutions
      header = "Correct solution"

      header += "s" if possible_solutions.length > 1

      @prompt.error "#{header}:\n#{possible_solutions.join(", ")}"

      return false
    end

    def used_wrong_word corrected_answer
      @prompt.error "You used the wrong word."
      @prompt.error colorize(corrected_answer) { |x| @pastel.red x }

      return false
    end
  end
end
