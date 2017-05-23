require "linguado/version"
require "linguado/lesson"
require "linguado/speaker"
require "linguado/word_policy"
require "linguado/runner"
require "linguado/database"
require "linguado/recorder"
require "linguado/course"
require "linguado/application"

module Linguado
  class << self
    def application
      @application ||= Linguado::Application.new
    end
  end
end
