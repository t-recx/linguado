require 'artii'
require 'etc'
require 'tty-prompt'

module Linguado
  class Application
    def initialize kernel = nil, artii = nil, dir = nil, prompt = nil
      @kernel = kernel || Kernel
      @artii = artii || Artii::Base.new
      @dir = dir || Dir
      @prompt = prompt || TTY::Prompt.new
      @exit = 'Exit'
    end

    def run
      @kernel.puts @artii.asciify('linguado') 
      @kernel.puts
      @kernel.puts "Version #{Linguado::VERSION}"
      @kernel.puts "Welcome back, #{user_name}" 
      
      require_course_files

      return @kernel.puts "No courses found! Please put some in the #{@dir.home}/.linguado directory and try again" if courses.empty? 

      while (selection = select_course) != @exit 
        courses.select { |c| c.name == selection }.first.work
      end
    end

    def require_course_files
      @dir.glob("#{@dir.home}/.linguado/**/*_course.rb").each do |course_file|
        @kernel.require course_file
      end
    end

    def select_course
      @prompt.select 'Select course', courses.map { |c| c.name }.sort { |a,b| a <=> b } + [@exit]
    end

    def user_name
      Etc.getpwnam(Etc.getlogin).gecos.split(/,/).first
    end

    def courses
      @courses ||= ObjectSpace.each_object(::Class).select { |klass| klass < Linguado::Course }.map { |klass| klass.new }
    end
  end
end
