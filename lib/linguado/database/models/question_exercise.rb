require 'sequel'

module Linguado::Database::Models
  class QuestionExercise < Sequel::Model
    many_to_one :question
  end
end
