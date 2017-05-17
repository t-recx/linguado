require 'sequel'
include Linguado::Database::Models

module Linguado
  class Recorder
    def record_word course_name, actual_word, word_used, correct
      course = Course.where(name: course_name).first

      course = Course.create(name: course_name) if course == nil 

      word = Word.where(name: actual_word, course: course).first

      word = Word.create(name: actual_word, course_id: course.pk) if word == nil

      mistaken_with = correct ? nil : word_used

      WordExercise.create(word_id: word.pk, correct: correct, mistaken_with: mistaken_with)
    end

    def get_word_exercises course_name, word
      WordExercise.where(word: Word.where(name: word, course: Course.where(name: course_name))).map { |x| x.values }
    end
  end
end
