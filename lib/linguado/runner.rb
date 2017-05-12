require 'pastel'
require 'tty-cursor'
require 'tty-screen'
require 'tty-progressbar'

module Linguado
  class Runner
    include TTY::Cursor
    attr_accessor :progress_bar

    def initialize kernel = nil, progress_bar_module = nil, screen = nil, pastel = nil
      @kernel = kernel || Kernel
      @progress_bar_module = progress_bar_module || TTY::ProgressBar
      @screen = screen || TTY::Screen
      @pastel = pastel || Pastel.new
      @progress_bar = nil
    end

    def run questions, delta_answers_required = 20
      @progress_bar = @progress_bar_module.new "[:bar]", total: delta_answers_required, width: @screen.width, complete: @pastel.on_green(' ')

      delta_answers = 0
      questions_asked = 0
      difference = 0

      if questions and not questions.empty? then
        shuffled_questions = []

        loop do
          print_lesson_status "Question #{questions_asked + 1}", difference

          shuffled_questions = questions.shuffle if shuffled_questions.empty?

          correct = shuffled_questions.pop.call 
          difference = (correct ? 1 : -1)
          
          @kernel.gets

          difference = 0 if difference == -1 and delta_answers <= 0

          delta_answers += difference

          questions_asked += 1

          break if delta_answers == delta_answers_required
        end
      end

      print_lesson_status "Lesson complete. Good job!", difference

      return questions_asked
    end

    def print_lesson_status header, difference
      @kernel.print clear_screen
      @kernel.print move_to

      @kernel.puts header
      @progress_bar.advance difference
    end
  end
end
