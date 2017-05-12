require 'test_helper'
require 'linguado'
require 'fakes/fake_prompt'
require 'fakes/fake_speaker'
require 'fakes/fake_word_policy'
require 'fakes/fake_pastel'
require 'fakes/fake_thread'

include Linguado

describe Lesson do
  let(:prompt) { FakePrompt.new }
  let(:speaker) { FakeSpeaker.new }
  let(:pastel) { FakePastel.new }
  let(:thread) { FakeThread }
  let(:word_policy) { FakeWordPolicy.new }
  let(:word_policies) { [] }

  subject { Lesson.new prompt, speaker, pastel, thread, word_policies: word_policies }

  describe :question do
    it "should store question on array" do
      q = Proc.new { }

      subject.question &q

      subject.questions.must_include q
    end
  end

  describe :translate do
    it "should call prompt.say" do
      subject.translate "a", "b"

      prompt.says.must_equal ['Translate this text', 'a']
    end

    it "should call prompt.ask" do
      subject.translate "test", "test"

      prompt.questions.must_include ">"
    end

    it "should call prompt.ok if translation correct" do
      prompt.setup_answer ">", "hello"

      return_value = subject.translate "hallo", "hello"

      assert_okay!
      return_value.must_equal true
    end

    it "should ignore casing when checking translation" do
      prompt.setup_answer ">", "heLlO"

      subject.translate "hallo", "hello", "hi"

      assert_okay!
    end

    it "should accept any of the proposed translations" do
      prompt.setup_answer ">", "hi"

      subject.translate "hallo", "hello", "hi"

      prompt.answers.clear
      prompt.setup_answer ">", "hello"

      subject.translate "hallo", "hello", "hi"

      prompt.okays.count.must_equal 2
    end

    it "should call prompt.error if translation incorrect" do
      prompt.setup_answer ">", "goodbye"

      return_value = subject.translate "hallo", "hello"

      assert_error! "hello"
      return_value.must_equal false
    end

    describe "with active policies" do
      let(:word_policies) { [word_policy] }

      it "should check for policies for all words when answer differs" do
        answer = "hi I am silly"
        tokens_answer = answer.downcase.split
        prompt.setup_answer ">", answer

        subject.translate "hallo ich bin müde", "hi I am tired"

        word_policy.passes.count.must_equal tokens_answer.count
        word_policy.typos.count.must_equal tokens_answer.count
        word_policy.passes.map { |p| p[:word].downcase }.must_equal tokens_answer
        word_policy.typos.map { |p| p[:word].downcase }.must_equal tokens_answer
      end

      it "should point out the typos when answers have them" do
        word_policy.typos_return[["scik", "sick"]] = true
        prompt.setup_answer ">", "hi I am scik"

        subject.translate "hallo ich bin krank", "hi I am sick"

        prompt.okays.must_include "Almost Correct!"
        prompt.okays.must_include "hi I am _sick_"
      end

      it "should be okay if answer has more words than the correct answer" do
        word_policy.passes_return[["hi", "hi"]] = true
        word_policy.default_passes_return = false
        prompt.setup_answer ">", "hi two three"

        subject.translate "hallo", "hi"

        assert_error! "hi"
      end
    end

    describe "with real world word policies" do
      let(:ein_word_policy) { WordPolicy.new condition: lambda { |word| word == 'ein' }, exceptions: ['einen', 'eine'], levenshtein_distance_allowed: 0 }
      let(:general_word_policy) { WordPolicy.new levenshtein_distance_allowed: 2 }

      let(:word_policies) { [ein_word_policy, general_word_policy] }

      it "should fail if ein not spelled correctly" do
        prompt.setup_answer ">", "ich bin eine hund"

        subject.write "ich bin ein hund"

        prompt.errors.must_include "You used the wrong word."
        prompt.errors.must_include "ich bin _ein_ hund"
      end

      it "should mark as correct if there are some typos" do
        prompt.setup_answer ">", "Halo ihc bin Aleine"

        subject.translate "Hi I am alone", "Hallo ich bin Alleine"

        prompt.okays.must_include "Almost Correct!"
        prompt.okays.must_include "_Hallo_ _ich_ bin _Alleine_"
      end
    end
  end

  describe :choose do
    let(:title) { "___ katze ist nett" }
    let(:correct) { "die" }
    let(:incorrect) { ["das", "der"] }

    it "should call prompt.say" do
      subject.choose title, correct, incorrect

      prompt.says.must_equal ["Choose the correct option", title]
    end

    it "should call prompt.select" do
      subject.choose title, correct, incorrect

      selection = prompt.selections.first
      selection[:title].must_equal '>'
      selection[:choices].must_equal [correct] + incorrect
      selection[:options][:enum].must_equal ')'
    end

    it "should call prompt.ok if answer correct" do
      prompt.setup_answer '>', correct

      return_value = subject.choose title, correct, incorrect

      assert_okay!
      return_value.must_equal true
    end

    it "should call prompt.error if incorrect answers are selected" do
      prompt.setup_answer '>', incorrect.shuffle.first

      return_value = subject.choose(title, correct, incorrect)

      assert_error! correct
      return_value.must_equal false
    end
  end

  describe :select do
    let(:title) { "The bread is good" }
    let(:correct) { ["Die Brot ist gut", "Brot ist gut"] }
    let(:incorrect) { ["Die Brot ist müde"] }

    it "should call prompt.say" do
      subject.select title, correct, incorrect

      prompt.says.must_equal ["Select all correct translations", title]
    end

    it "should call prompt.multi_select" do
      subject.select title, correct, incorrect

      selection = prompt.multi_selections.first
      selection[:title].must_equal '>'
      selection[:choices].must_equal correct + incorrect
      selection[:options][:enum].must_equal ")"
    end

    it "should call prompt.ok if all correct answers are selected" do
      prompt.setup_answer '>', correct

      return_value = subject.select(title, correct, incorrect)

      assert_okay!
      return_value.must_equal true
    end

    it "should call prompt.error if incorrect answers are selected" do
      prompt.setup_answer '>', correct + [incorrect.first]

      return_value = subject.select(title, correct, incorrect)

      assert_error! correct
      return_value.must_equal false
    end
  end

  describe :write do
    it "should call speaker.speak" do
      subject.write "abc"

      speaker.sentences.first[:sentence].must_equal "abc"
    end

    it "should pass correct language code from the lesson to speaker" do
      subject.language = "de-DE"

      subject.write "abc"

      speaker.sentences.first[:language].must_equal "de-DE"
    end

    it "should call prompt.say" do
      subject.write "abc"

      prompt.says.first.must_equal "Type what you hear"
    end

    it "should call prompt.ask" do
      subject.write "abc"

      prompt.questions.first.must_equal ">"
    end

    it "should call prompt.ok if correct response" do
      prompt.setup_answer ">", "abc"

      return_value = subject.write "abc"

      assert_okay!
      return_value.must_equal true
    end

    it "should call prompt.error if incorrect response" do
      prompt.setup_answer ">", "incorrect"

      return_value = subject.write "abc"

      assert_error! "abc"
      return_value.must_equal false
    end
  end

  describe :correct? do
    it "should ignore punctuation" do
      subject.correct?('the,    cat! is so. tired 123?', 'the cat is so tired 123').must_equal true
      subject.correct?('dIE KaTze ist sehr müde 123', 'die, katze! ist sehr. müde    123?').must_equal true
    end
  end

  describe :prepare do
    it "should keep diacritics and friends" do
      characters = "äëïöüß'"
      subject.prepare(characters).must_equal characters
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
