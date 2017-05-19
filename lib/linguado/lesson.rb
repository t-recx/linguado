require 'tty-prompt'
require 'pastel'

module Linguado
  class Lesson
    attr_accessor :prompt
    attr_accessor :speaker
    attr_accessor :pastel
    attr_accessor :thread
    attr_accessor :recorder
    attr_accessor :questions
    attr_accessor :language
    attr_accessor :word_policies
    attr_accessor :course_name

    def initialize(prompt = nil, speaker = nil, pastel = nil, thread = nil, recorder = nil, language: 'en-US', word_policies: [], course_name: nil)
      @language = language
      @word_policies = word_policies
      @prompt = prompt || TTY::Prompt.new 
      @speaker = speaker || Speaker.new
      @pastel = pastel || Pastel.new
      @thread = thread || Thread
      @recorder = recorder || Recorder.new
      @questions = []
      @course_name = course_name
    end

    def ask_to opts = {}
      opts[:question] = get_question_call opts

      @questions.push opts
    end

    def get_question_call opts
      opts[:answer] = opts[:answers] if opts.keys.include? :answers
      opts[:answers] = opts[:answer] if opts.keys.include? :answer

      return lambda { write opts[:write] } if opts.keys.include? :write
      return lambda { choose opts[:choose], opts[:answer], opts[:wrong] } if opts.keys.include? :choose 
      return lambda { translate opts[:translate], *opts[:answers] } if opts.keys.include? :translate
      return lambda { select opts[:select], opts[:answers], opts[:wrong] } if opts.keys.include? :select
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

      return correct!(answer) if exact_match answer, correct

      record_wrong_choice answer, correct

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

      possibilities.any? { |possibility| prepare(answer) == prepare(possibility) }
    end

    def prepare s
      s.downcase.gsub(/[^\p{ALPHA}\w\s\"'"]/, ' ').split.join(' ')
    end

    def correct? answer, *possibilities
      return false unless answer

      answer = prepare(answer)

      return correct!(answer) if exact_match answer, *possibilities 

      if word_policies and word_policies.count > 0 then
        tokens_answer = answer.split
        used_wrong_words = false
        correct_words = []
        wrong_words = []
        corrected_answer = ""

        possibilities.each do |possibility|
          correct_words.clear
          wrong_words.clear

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
              wrong_words.push([token_possibility, token])
            else
              typo = word_policies.any? { |policy| policy.typo? token, tokens_possibility[i] }

              if typo then
                corrected_answer += "#{@pastel.underline(token_possibility)} "
              else
                corrected_answer += "#{token_possibility} "
              end

              correct_words.push token_possibility
            end
          end

          corrected_answer.strip!

          if passed_policies then
            record_correct correct_words

            return almost_correct!(corrected_answer) 
          end
        end

        if used_wrong_words then
          record correct_words, wrong_words

          return used_wrong_word(corrected_answer) 
        end
      end

      error possibilities.first
    end

    def correct! answer = nil
      record_correct(answer.split) if answer

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

    def record_correct words
      words.map { |word| recorder.record_word_exercise course_name, word }
    end

    def record_wrong words
      words.map { |word, wrong_word| recorder.record_word_exercise course_name, word, wrong_word, false }
    end

    def record_wrong_choice answer, correct
      return unless answer

      wrong_words = []
      answer.split.each_with_index do |word, i|
        wrong_words.push [correct.split[i], word]
      end

      record_wrong wrong_words
    end

    def record correct_words, wrong_words
      record_correct correct_words
      record_wrong wrong_words
    end
  end
end
