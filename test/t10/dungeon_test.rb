require 'test_helper'

class T10::DungeonTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::T10::Dungeon::VERSION
  end
end
