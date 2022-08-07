require 'test_helper'
require 'linguado'
require 'tty-cursor'
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
  let(:pastel) do  
    p = FakePastel.new 
    def p.on_green(s); 'G'; end

    p
  end

  subject { Runner.new kernel, progress_bar_module, screen, pastel }

  describe :ask do
    it "should create a progress bar" do
      n = rand(10)

      subject.ask questions, n
      
      _(subject.progress_bar).must_be_instance_of FakeProgressBar
      _(subject.progress_bar.format).must_equal '[:bar]'
      _(subject.progress_bar.options[:total]).must_equal n
      _(subject.progress_bar.options[:width]).must_equal width
      _(subject.progress_bar.options[:complete]).must_equal 'G'
    end

    it "should be alright if no questions are supplied" do
      subject.ask []
      subject.ask nil
    end

    it "should ask all questions repeatedly until delta answers reached" do
      question_a_called = question_b_called = question_c_called = 0
      questions.push get_question { question_a_called += 1 }
      questions.push get_question { question_b_called += 1 }
      questions.push get_question { question_c_called += 1 }

      subject.ask questions, 9

      _(question_a_called).must_equal 3
      _(question_b_called).must_equal 3
      _(question_c_called).must_equal 3
    end

    it "after each question should clear screen and reposition cursor" do
      questions.push get_question

      subject.ask questions, 4
      
      5.times do 
        _(kernel.prints.pop).must_equal move_to
        _(kernel.prints.pop).must_equal clear_screen
      end

      _(kernel.prints.count).must_equal 0
    end

    it "after each question should update progress bar" do
      questions.push get_question with_failures: 2, after_being_called: 2

      subject.ask questions, 4

      _(subject.progress_bar.advance_stack.count { |x| x == 1 }).must_equal 6
      _(subject.progress_bar.advance_stack.count { |x| x == -1 }).must_equal 2
    end

    it "should keep asking question until the sum of correct and incorrect answers equals passed parameter" do
      questions.push get_question with_failures: 2, after_being_called: 4 

      rv = subject.ask(questions, 10)
      _(rv.first).must_equal 14
      _(rv.drop(1).first).must_equal 12
    end

    it "correct answer count should never drop into negative territory" do
      questions.push get_question with_failures: 2

      rv = subject.ask(questions, 10)
      _(rv.first).must_equal 12
      _(rv.drop(1).first).must_equal 10 
    end

    it "should show question header before each question" do
      questions.push get_question

      subject.ask questions, 10

      10.times { |i| _(kernel.puts_array[i]).must_equal "Question #{i + 1}" }
    end

    it "should call gets after every question" do
      questions.push get_question

      subject.ask questions, 10

      _(kernel.gets_calls).must_equal 10 
    end

    it "should not be advancing the progress bar into negative territory when delta already 0 or less" do
      questions.push get_question with_failures: 10

      subject.ask questions, 10

      _(subject.progress_bar.advance_stack.count { |x| x == -1 }).must_equal 0
      _(subject.progress_bar.advance_stack.count { |x| x == 1 }).must_equal 10
    end
  end

  def get_question with_failures: 0, after_being_called: 0, &block
    q = {}
    times_called = 0

    q[:question] = lambda do
      times_called += 1
      block.call if block

      if with_failures > 0 and times_called > after_being_called
        with_failures -= 1

        return false
      end
      
      return true
    end 

    q
  end
end
