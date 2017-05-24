require 'sequel'
include Linguado::Database::Models

module Linguado
  class Recorder
    def record_word_exercise course_name, actual_word, word_used = nil, correct = true
      course = get_course course_name

      word = get_word course.pk, actual_word

      mistaken_with = correct ? nil : word_used

      WordExercise.create(word_id: word.pk, correct: correct, mistaken_with: mistaken_with)
    end

    def record_question_exercise course_name, type, question_description, answer, correct
      course = get_course course_name

      question = get_question course.pk, type, question_description

      QuestionExercise.create(question_id: question.pk, correct: correct, answer: answer)
    end

    def record_lesson_exercise course_name, lesson_name, questions_asked, correct_answers
      course = get_course course_name

      lesson = get_lesson course.pk, lesson_name

      LessonExercise.create(lesson_id: lesson.pk, questions: questions_asked, correct_answers: correct_answers)
    end

    def get_lesson_exercises course_name, lesson_name
      LessonExercise.where(lesson: Database::Models::Lesson.where(course: Database::Models::Course.where(name: course_name), name: lesson_name)).map { |x| x.values }
    end

    def get_question_exercises course_name, type, question_description
      QuestionExercise.where(question: Question.where(course: Database::Models::Course.where(name: course_name), type: type, question: question_description)).map { |x| x.values }
    end

    def get_word_exercises course_name, word
      WordExercise.where(word: Word.where(name: word, course: Database::Models::Course.where(name: course_name))).map { |x| x.values }
    end

    def already_passed_lesson course_name, lesson_name
      not LessonExercise.where(lesson: Database::Models::Lesson.where(course: Database::Models::Course.where(name: course_name), name: lesson_name)).empty?
    end

    def get_course course_name
      course = Database::Models::Course.where(name: course_name).first

      course = Database::Models::Course.create(name: course_name) unless course

      return course
    end

    def get_word course_id, actual_word
      word = Word.where(name: actual_word, course_id: course_id).first

      word = Word.create(name: actual_word, course_id: course_id) unless word

      return word
    end

    def get_question course_id, type, question_description
      question = Question.where(course_id: course_id, type: type, question: question_description).first

      question = Question.create(course_id: course_id, type: type, question: question_description) unless question

      return question
    end

    def get_lesson course_id, lesson_name
      lesson = Database::Models::Lesson.where(course_id: course_id, name: lesson_name).first

      lesson = Database::Models::Lesson.create(course_id: course_id, name: lesson_name) unless lesson

      return lesson
    end
  end
end
