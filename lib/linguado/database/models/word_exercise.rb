require 'sequel'

module Linguado::Database::Models
  class WordExercise < Sequel::Model
    many_to_one :word
  end
end
