require 'artii'
require 'etc'
require 'tty-prompt'

module Linguado
  class Application
    attr_accessor :courses

    def initialize kernel = nil, artii = nil, dir = nil, prompt = nil
      @kernel = kernel || Kernel
      @artii = artii || Artii::Base.new
      @dir = dir || Dir
      @prompt = prompt || TTY::Prompt.new
      @courses = []
    end

    def run
      @artii.asciify 'linguado'
      @kernel.puts "Version #{Linguado::VERSION}"
      @kernel.puts "Welcome back, #{Etc.getpwnam(Etc.getlogin).gecos.split(/,/).first}" 
      
      @dir.glob("#{@dir.home}/.linguado/**/*_course.rb").each do |course_file|
        @kernel.require course_file
      end

      @courses = get_courses

      if @courses.empty? then
        @kernel.puts "No courses found! Please put some in the #{@dir.home}/.linguado directory and try again" 
        return 
      end

      loop do
        selection = @prompt.select 'Select course', @courses.map { |c| c.name }.sort { |a,b| a <=> b } + ['Exit']

        break if selection == 'Exit' 

        @courses.select { |c| c.name == selection }.first.work
      end
    end

    def get_courses
      ObjectSpace.each_object(::Class).select { |klass| klass < Linguado::Course }.map { |klass| klass.new }
    end
  end
end
