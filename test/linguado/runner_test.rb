require 'test_helper'
require 'linguado'
require 'tty-cursor'
require 'fakes/fake_lesson.rb'
require 'fakes/fake_kernel.rb'
require 'fakes/fake_progress_bar.rb'
require 'fakes/fake_screen.rb'
require 'fakes/fake_pastel.rb'

include Linguado
include TTY::Cursor

describe Runner do
  let(:questions) { [] }
  let(:kernel) { FakeKernel.new }
  let(:cursor) { FakeCursor.new }
  let(:width) { 13 }
  let(:screen) { FakeScreen.new width }
  let(:progress_bar_module) { FakeProgressBar }
  let(:lesson) { FakeLesson.new questions }
  let(:pastel) do  
    p = FakePastel.new 
    def p.on_green(s); 'G'; end

    p
  end

  subject { Runner.new kernel, progress_bar_module, screen, pastel }

  describe :run do
    it "should create a progress bar" do
      n = rand(10)

      subject.run questions, n
      
      subject.progress_bar.must_be_instance_of FakeProgressBar
      subject.progress_bar.format.must_equal '[:bar]'
      subject.progress_bar.options[:total].must_equal n
      subject.progress_bar.options[:width].must_equal width
      subject.progress_bar.options[:complete].must_equal 'G'
    end

    it "should be alright if no questions are supplied" do
      subject.run []
      subject.run nil
    end

    it "should run all questions repeatedly until delta answers reached" do
      question_a_called = question_b_called = question_c_called = 0
      questions.push get_question { question_a_called += 1 }
      questions.push get_question { question_b_called += 1 }
      questions.push get_question { question_c_called += 1 }

      subject.run questions, 9

      question_a_called.must_equal 3
      question_b_called.must_equal 3
      question_c_called.must_equal 3
    end

    it "after each question should clear screen and reposition cursor" do
      questions.push lambda { true }

      subject.run questions, 4
      
      5.times do 
        kernel.prints.pop.must_equal move_to
        kernel.prints.pop.must_equal clear_screen
      end

      kernel.prints.count.must_equal 0
    end

    it "after each question should update progress bar" do
      questions.push get_question with_failures: 2, after_being_called: 2

      subject.run questions, 4

      subject.progress_bar.advance_stack.count { |x| x == 1 }.must_equal 6
      subject.progress_bar.advance_stack.count { |x| x == -1 }.must_equal 2
    end

    it "should keep asking question until the sum of correct and incorrect answers equals passed parameter" do
      questions.push get_question with_failures: 2, after_being_called: 4 

      subject.run(questions, 10).must_equal 14
    end

    it "correct answer count should never drop into negative territory" do
      questions.push get_question with_failures: 2

      subject.run(questions, 10).must_equal 12
    end

    it "should show question header before each question" do
      questions.push get_question

      subject.run questions, 10

      10.times { |i| kernel.puts_array[i].must_equal "Question #{i + 1}" }
    end

    it "should call gets after every question" do
      questions.push get_question

      subject.run questions, 10

      kernel.gets_calls.must_equal 10 
    end
  end

  def get_question with_failures: 0, after_being_called: 0, &block
    times_called = 0

    lambda do
      times_called += 1
      block.call if block

      if with_failures > 0 and times_called > after_being_called
        with_failures -= 1

        return false
      end
      
      return true
    end
  end
end
