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
      @progress_bar = @progress_bar_module.new "[:bar]", total: 10, width: @screen.width, complete: @pastel.on_green(' ')

      delta_answers = 0
      questions_asked = 0

      if questions and not questions.empty? then
        shuffled_questions = []

        loop do
          @kernel.print clear_screen
          @kernel.print move_to

          @kernel.puts "Question #{questions_asked + 1}"

          @progress_bar.advance 0

          shuffled_questions = questions.shuffle if shuffled_questions.empty?

          correct = shuffled_questions.pop.call 
          difference = (correct ? 1 : -1)
          
          unless difference == -1 and delta_answers == 0 then 
            delta_answers += difference
            @progress_bar.advance difference
          end

          questions_asked += 1

          break if delta_answers == delta_answers_required
        end
      end

      return questions_asked
    end
  end
end
