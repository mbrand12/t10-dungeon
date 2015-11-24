$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 't10/dungeon'

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use!
