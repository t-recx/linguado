require 'sequel'

module Linguado::Database::Models
  class LessonExercise < Sequel::Model
    many_to_one :lesson
  end
end
