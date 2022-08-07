require 'test_helper'
require 'linguado'
include Linguado
include Linguado::Database::Models

describe Recorder do
  let(:course) { "German" }
  let(:actual_word) { "Word" }
  let(:word_used) { "Word" }
  let(:correct) { true }
  let(:type) { "write" }
  let(:question) { "question?" }
  let(:answer) { "answer!" }
  let(:lesson) { "lesson" }
  let(:questions) { 20 }
  let(:correct_answers) { 10 }

  subject { Recorder.new }

  around do |&block|
    Sequel::Model.db.transaction(:rollback=>:always, :auto_savepoint=>true) do
      super &block
    end
  end

  describe :record_word_exercise do
    it "should create course if it doesn't exist" do
      exercise_record_word

      _(Database::Models::Course.first.name).must_equal course
      _(Database::Models::Course.first.created_at).wont_equal nil
      _(Database::Models::Course.count).must_equal 1
    end

    it "shouldn't create more than one course with the same name" do
      exercise_record_word
      exercise_record_word

      _(Database::Models::Course.count).must_equal 1
    end

    it "should create word if it doesn't exist" do
      exercise_record_word

      _(Word.first.name).must_equal actual_word
    end

    it "shouldn't create more than one word with the same name" do
      exercise_record_word
      exercise_record_word

      _(Word.count).must_equal 1
    end

    it "should create a record on word_exercise_record_words" do
      exercise_record_word aw: 'xxx'
      exercise_record_word aw: actual_word, c: false, wu: 'abc'
      exercise_record_word aw: actual_word, c: true, wu: 'gfkjf'
      exercise_record_word cs: 'zyx'

      _(WordExercise.count).must_equal 4
      _(subject.get_word_exercises(course, actual_word).count).must_equal 2
      _(subject.get_word_exercises('zyx', actual_word).count).must_equal 1
      _(subject.get_word_exercises(course, 'xxx').count).must_equal 1
    end
  end

  describe :record_question_exercise do
    it "should create course if it doesn't exist" do
      exercise_record_question

      _(Database::Models::Course.first.name).must_equal course
      _(Database::Models::Course.first.created_at).wont_equal nil
      _(Database::Models::Course.count).must_equal 1
    end

    it "shouldn't create more than one course with the same name" do
      exercise_record_question
      exercise_record_question

      _(Database::Models::Course.count).must_equal 1
    end

    it "should create question if it doesn't exist" do
      exercise_record_question

      _(Question.first.question).must_equal question
    end

    it "shouldn't create more than one question with the same name" do
      exercise_record_question
      exercise_record_question

      _(Question.count).must_equal 1
    end

    it "should create question exercise records" do
      exercise_record_question 
      exercise_record_question cs: 'abc'
      exercise_record_question t: 'translate', q: 'one'
      exercise_record_question t: 'translate', q: 'one'

      _(QuestionExercise.count).must_equal 4
      _(subject.get_question_exercises('abc', type, question).count).must_equal 1
      _(subject.get_question_exercises(course, type, question).count).must_equal 1
      _(subject.get_question_exercises(course, 'translate', 'one').count).must_equal 2
    end
  end

  describe :record_lesson_exercise do 
    it "should create lesson if it doesn't exist" do
      exercise_record_lesson

      _(Database::Models::Lesson.first.name).must_equal lesson
      _(Database::Models::Lesson.first.created_at).wont_equal nil
      _(Database::Models::Lesson.count).must_equal 1
    end

    it "shouldn't create more than one lesson with the same name" do
      exercise_record_lesson
      exercise_record_lesson

      _(Database::Models::Lesson.count).must_equal 1
    end

    it "should create lesson exercises" do
      exercise_record_lesson
      exercise_record_lesson
      exercise_record_lesson

      _(subject.get_lesson_exercises(course, lesson).count).must_equal 3
    end
  end

  describe :already_passed_lesson do
    it "should return false if no record of lesson already on database" do
      _(subject.already_passed_lesson(course, lesson)).must_equal false
    end

    it "should return true if already has record of lesson on database" do
      subject.record_lesson_exercise course, lesson, 10, 10

      _(subject.already_passed_lesson(course, lesson)).must_equal true
    end
  end

  describe :get_word_exercise_record_words do
    it "should be alright when no records present" do
      _(subject.get_word_exercises('abc', 'def').count).must_equal 0
    end
  end

  describe :get_question_exercises do
    it "should be alright when no records present" do
      _(subject.get_question_exercises('a', 'b', 'c').count).must_equal 0
    end
  end

  describe :get_lesson_exercises do
    it "should be alright when no records present" do
      _(subject.get_lesson_exercises('a', 'b').count).must_equal 0
    end
  end

  def exercise_record_lesson
    subject.record_lesson_exercise course, lesson, questions, correct_answers  
  end

  def exercise_record_word cs: course, aw: actual_word, wu: word_used, c: correct
    subject.record_word_exercise cs, aw, wu, c
  end

  def exercise_record_question cs: course, t: type, q: question, a: answer, c: correct
    subject.record_question_exercise cs, t, q, a, c
  end
end
