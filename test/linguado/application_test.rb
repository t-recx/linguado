require 'test_helper'
require 'etc'
require 'linguado'
require 'fakes/fake_kernel'
require 'fakes/fake_artii'
require 'fakes/fake_dir'
require 'fakes/fake_prompt'

include Linguado

describe Application do
  let(:kernel) { FakeKernel.new }
  let(:artii) { FakeArtii.new }
  let(:dir) { FakeDir.new }
  let(:prompt) { FakePrompt.new }

  subject { Application.new kernel, artii, dir, prompt }

  before(:all) do
    class GermanCourse < Course; end;
    class ItalianCourse < Course; end;
  end

  describe :run do
    describe "when there are no courses available" do
      before do
        def subject.courses; []; end
      end

      it "should print logo" do
        subject.run

        artii.asciifies.count { |a| a == 'linguado' }.must_equal 1
        kernel.puts_array.first.must_equal 'linguado'
      end

      it "should print version" do
        subject.run

        kernel.puts_array.drop(2).first.must_equal "Version #{Linguado::VERSION}"
      end

      it "should welcome user" do
        subject.run

        kernel.puts_array.drop(3).first.must_equal "Welcome back, #{Etc.getpwnam(Etc.getlogin).gecos.split(/,/).first}"  
      end

      it "should require all course files in home directory" do
        courses = ['a_course.rb', 'b_course.rb']
        dir.home = '/whatever'
        dir.globs["#{dir.home}/.linguado/**/*_course.rb"] = courses

        subject.run

        kernel.requires.must_equal courses
      end

      it "should inform there are no courses available if that's the case" do
        subject.run

        kernel.puts_array.drop(4).first.must_equal "No courses found! Please put some in the #{dir.home}/.linguado directory and try again"
      end
    end

    describe "when there are courses available" do
      it "should instantiate all courses and put them in the courses array" do
        setup_exit

        subject.run
        subject.courses.count { |course| course.is_a? GermanCourse }.must_equal 1
        subject.courses.count { |course| course.is_a? ItalianCourse }.must_equal 1
        subject.courses.count.must_equal 2
      end

      it "should allow the user to choose which course they want" do
        c = setup_test_course
        prompt.setup_answer 'Select course', 'Test'
        setup_exit

        subject.run

        c.work_called.must_equal true
      end

      it "should loop until user decides to exit" do
        c = setup_test_course
        prompt.setup_answer 'Select course', 'Test'
        prompt.setup_answer 'Select course', 'Test'
        setup_exit

        subject.run

        c.times_called.must_equal 2
      end
    end
  end

  def setup_exit
    prompt.setup_answer 'Select course', 'Exit'
  end

  def setup_test_course
    c = Object.new

    def c.name; 'Test'; end
    def c.work; @work_called = true; @times_called = 0 unless @times_called; @times_called += 1; end
    def c.work_called; @work_called; end
    def c.times_called; @times_called; end
    def subject.test_courses= v; @test_courses = v; end
    def subject.courses; @test_courses; end
    subject.test_courses = [c]

    return c
  end
end
