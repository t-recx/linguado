require "linguado/version"
require "linguado/lesson"
require "linguado/speaker"
require "linguado/word_policy"
require "linguado/runner"
require "linguado/database/schema"
require 'sequel'
require 'sequel/plugins/timestamps'

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
require "linguado/recorder"

module Linguado
end
