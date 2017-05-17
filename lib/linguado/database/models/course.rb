require 'sequel'

module Linguado::Database::Models
  class Course < Sequel::Model
    one_to_many :words
    one_to_many :lessons
  end
end
