require 'sequel'

module Linguado::Database::Models
  class Question < Sequel::Model
    many_to_one :course
    one_to_many :question_exercises
  end
end
