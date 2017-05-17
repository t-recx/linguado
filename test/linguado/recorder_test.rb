require 'test_helper'
require 'linguado'
include Linguado
include Linguado::Database::Models

describe Recorder do
  let(:course) { "German" }
  let(:actual_word) { "Word" }
  let(:word_used) { "Word" }
  let(:correct) { true }

  subject { Recorder.new }

  around do |&block|
    Sequel::Model.db.transaction(:rollback=>:always, :auto_savepoint=>true) do
      super &block
    end
  end

  describe :record_word do
    it "should create course if it doesn't exist" do
      exercise_record_word

      Course.first.name.must_equal course
      Course.first.created_at.wont_equal nil
      Course.count.must_equal 1
    end

    it "shouldn't create more than one course with the same name" do
      exercise_record_word
      exercise_record_word

      Course.count.must_equal 1
    end

    it "should create word if it doesn't exist" do
      exercise_record_word

      Word.first.name.must_equal actual_word
    end

    it "shouldn't create more than one word with the same name" do
      exercise_record_word
      exercise_record_word

      Word.count.must_equal 1
    end

    it "should create a record on word_exercise_record_words" do
      exercise_record_word aw: 'xxx'
      exercise_record_word aw: actual_word, c: false, wu: 'abc'
      exercise_record_word aw: actual_word, c: true, wu: 'gfkjf'
      exercise_record_word cs: 'zyx'

      WordExercise.count.must_equal 4
      subject.get_word_exercises(course, actual_word).count.must_equal 2
      subject.get_word_exercises('zyx', actual_word).count.must_equal 1
      subject.get_word_exercises(course, 'xxx').count.must_equal 1
    end
  end

  describe :get_word_exercise_record_words do
    it "should be alright when no records present" do
      subject.get_word_exercises('abc', 'def').count.must_equal 0
    end
  end

  def exercise_record_word cs: course, aw: actual_word, wu: word_used, c: correct
    subject.record_word cs, aw, wu, c
  end
end
