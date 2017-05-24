class FakeRecorder
  attr_accessor :word_exercises_recorded
  attr_accessor :question_exercises_recorded
  attr_accessor :lesson_exercises_recorded
  attr_accessor :word_exercises
  attr_accessor :question_exercises
  attr_accessor :lesson_exercises
  attr_accessor :already_passed_lessons

  def initialize
    @word_exercises_recorded = []
    @question_exercises_recorded = []
    @lesson_exercises_recorded = []
    @word_exercises = {}
    @question_exercises = {}
    @lesson_exercises = {}
    @already_passed_lessons = {}
  end

  def record_word_exercise course_name, actual_word, word_used = nil, correct = true
    @word_exercises_recorded.push({ course: course_name, word: actual_word, word_used: word_used, correct: correct })
  end

  def record_question_exercise course_name, type, question_description, answer, correct
    @question_exercises_recorded.push({ course: course_name, type: type, question: question_description, answer: answer, correct: correct })
  end

  def record_lesson_exercise course_name, lesson_name, questions_asked, correct_answers
    @lesson_exercises_recorded.push({ course: course_name, lesson: lesson_name, questions: questions_asked, correct_answers: correct_answers })
  end

  def get_lesson_exercises course_name, lesson_name
    @lesson_exercises[{course: course_name, lesson: lesson_name}] || @lesson_exercises[{course: nil, lesson: nil}]
  end

  def get_question_exercises course_name, type, question_description
    @question_exercises[{course: course_name, type: type, question: question_description}]
  end

  def get_word_exercises course_name, word
    @word_exercises[{course: course_name, word: word}]
  end

  def already_passed_lesson course_name, lesson_name
    result = @already_passed_lessons[{course: course_name, lesson: lesson_name}] 
    
    result = @already_passed_lessons[{course: nil, lesson: nil}] if result == nil

    return result
  end

  def get_course course_name
  end

  def get_word course_id, actual_word
  end

  def get_question course_id, type, question_description
  end

  def get_lesson course_id, lesson_name
  end
end
