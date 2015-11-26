require 'test_helper'
require 'rooms'

class T10::DungeonTest < Minitest::Test
  def setup
    @generated_rooms = T10::Dungeon.generate(Room.rooms, EntranceRoom, ExitRoom)
  end

  def test_that_it_has_a_version_number
    refute_nil ::T10::Dungeon::VERSION
  end

  def test_room_connections
    # @generated_rooms.each {|room| puts room.to_str}
    assert @generated_rooms.all?(&:test_connections),
      "Rooms must be properly connected and oriented."
  end

  def test_dungeon_rooms_limit
    generated_rooms_limit = T10::Dungeon::ROOM_TYPE_LIMIT.inject(:+) + 2
    assert_equal generated_rooms_limit, @generated_rooms.size,
      "Number of generated rooms must be #{generated_rooms_limit}"
  end
end
