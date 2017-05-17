$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['LINGUADODB'] = ':memory:'
require 'linguado'

require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/hooks/default'

reporter_options = { color: true }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
