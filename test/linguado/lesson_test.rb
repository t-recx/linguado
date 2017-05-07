require 'test_helper'
require 'linguado'
require 'fakes/fake_prompt'
require 'fakes/fake_speaker'
include Linguado

describe Lesson do
  let(:prompt) { FakePrompt.new }
  let(:speaker) { FakeSpeaker.new }

  subject { Lesson.new prompt, speaker }

  describe :question do
    it "should store question on array" do
      q = Proc.new { }

      subject.question &q

      subject.questions.must_include q
    end
  end

  describe :run do
    it "should call all questions" do
      subject.question { subject.translate "abc", "abc" }
      subject.question { subject.translate "xyz", "xyz" }

      subject.run

      prompt.questions.must_include "abc"
      prompt.questions.must_include "xyz"
      prompt.questions.count.must_equal 2
    end

    it "should shuffle question array" do
      mock_questions = Minitest::Mock.new
      mock_questions.expect :shuffle, []
      subject.questions = mock_questions

      subject.run

      mock_questions.verify
    end
  end

  describe :translate do
    it "should call prompt.ask" do
      subject.translate "test", "test"

      prompt.questions.must_include "test"
    end

    it "should call prompt.ok if translation correct" do
      prompt.setup_answer "hallo", "hello"

      subject.translate "hallo", "hello"

      assert_okay!
    end

    it "should ignore casing when checking translation" do
      prompt.setup_answer "hallo", "heLlO"

      subject.translate "hallo", "hello", "hi"

      assert_okay!
    end

    it "should accept any of the proposed translations" do
      prompt.setup_answer "hallo", "hi"

      subject.translate "hallo", "hello", "hi"

      prompt.answers.clear
      prompt.setup_answer "hallo", "hello"

      subject.translate "hallo", "hello", "hi"

      prompt.okays.count.must_equal 2
    end

    it "should call prompt.error if translation incorrect" do
      prompt.setup_answer "hallo", "goodbye"

      subject.translate "hallo", "hello"

      assert_error! "hello"
    end
  end

  describe :select do
    let(:title) { "The bread is good" }
    let(:correct) { ["Die Brot ist gut", "Brot ist gut"] }
    let(:incorrect) { ["Die Brot ist müde"] }

    it "should call prompt.multi_select" do
      subject.select title, correct, incorrect

      selection = prompt.multi_selections.first
      selection[:title].must_equal title
      selection[:choices].must_equal correct + incorrect
      selection[:options][:enum].must_equal ")"
    end

    it "should call prompt.ok if all correct answers are selected" do
      prompt.setup_answer title, correct

      subject.select title, correct, incorrect

      assert_okay!
    end

    it "should call prompt.error if incorrect answers are selected" do
      prompt.setup_answer title, correct + [incorrect.first]

      subject.select title, correct, incorrect

      assert_error! correct
    end
  end

  describe :write do
    it "should call speaker.speak" do
      subject.write "abc"

      speaker.sentences.first.must_equal "abc"
    end

    it "should call prompt.ask" do
      subject.write "abc"

      prompt.questions.first.must_equal "Type what you hear"
    end

    it "should call prompt.ok if correct response" do
      prompt.setup_answer "Type what you hear", "abc"

      subject.write "abc"

      assert_okay!
    end

    it "should call prompt.error if incorrect response" do
      prompt.setup_answer "Type what you hear", "incorrect"

      subject.write "abc"

      assert_error! "abc"
    end
  end

  def assert_okay! text = "Correct!"
    prompt.okays.must_include text
  end

  def assert_error! *solutions
    header = "Correct solution"
    header += "s" if solutions.length > 1

    prompt.errors.first.must_equal "#{header}:\n#{solutions.join(", ")}"
  end
end
