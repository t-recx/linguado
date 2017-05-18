require 'sequel'
require 'sequel/plugins/timestamps'
require "linguado/database/schema"

DB = Sequel.sqlite ENV['LINGUADODB']
Linguado::Database::Schema.new.create_database

Sequel::Model.plugin :timestamps

require "linguado/database/models/course"
require "linguado/database/models/word"
require "linguado/database/models/word_exercise"
require "linguado/database/models/question"
require "linguado/database/models/question_exercise"
require "linguado/database/models/lesson"
require "linguado/database/models/lesson_exercise"

module Linguado::Database
end
