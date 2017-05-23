require 'tty-prompt'
require 'linguado/runner'
require 'linguado/recorder'

module Linguado
  class Course
    attr_accessor :topics
    attr_accessor :name

    def initialize prompt = nil, runner = nil, recorder = nil, name: nil
      @prompt = prompt || TTY::Prompt.new
      @runner = runner || Runner.new
      @recorder = recorder || Recorder.new
      @name = name || self.class.name.split('::').last.split(/(?=[A-Z])/).join(' ')
      @topics = []
      @back_text = 'Go Back'
    end

    def topic name, params = {}
      topic = { name: name }

      topic.merge!(params)

      @topics.push topic
    end

    def get_topic name
      @topics.first { |t| t[:name] == name }
    end

    def get_lesson ts, subject
      ts.select { |t| t[:name] == subject and t[:lesson] }.map { |t| t[:lesson] }.first
    end

    def work
      subject = nil
      subjects_transversed = [subject]

      loop do
        ts = @topics.select { |t| t[:in] == subject && (!t[:depends_upon] or @recorder.get_lesson_exercises(@name, t[:depends_upon]).count > 0) }

        subject = @prompt.select 'Select a lesson', ts.map { |t| t[:name] } + [@back_text]

        lesson = get_lesson ts, subject 

        if lesson then
          questions_asked, correct_answers = @runner.ask lesson.questions 
          @recorder.record_lesson_exercise @name, lesson.name, questions_asked, correct_answers
        end

        if subject == @back_text then
          break if subjects_transversed.empty?

          subjects_transversed.pop
          subject = subjects_transversed.pop
        else
          subjects_transversed.push subject
        end
      end
    end
  end
end
