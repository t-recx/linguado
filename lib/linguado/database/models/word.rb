require 'sequel'

module Linguado::Database::Models
  class Word < Sequel::Model
    one_to_many :word_exercises
    many_to_one :course
  end
end
