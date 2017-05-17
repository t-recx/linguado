require 'sequel'

module Linguado::Database::Models
  class Lesson < Sequel::Model
    many_to_one :course
  end
end
