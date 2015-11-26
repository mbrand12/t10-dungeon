require 'test_helper'
require 'rooms'

class TraversableTest < Minitest::Test
  def test_adding_one_room_too_much
    room1 = R21.new
    room2 = R12.new
    room3 = R13.new

    room1.prepare_entrance!
    room1.connect_to(room2)

    msg = "Room should not be able to be connected to the room that has" \
          "no doors left to be connected to."

    assert_raises(StandardError, msg) {room1.connect_to(room3)}
  end

  def test_adding_duplicate_rooms
    room1 = R31.new
    room2 = R11.new

    room1.prepare_entrance!
    room1.connect_to(room2)

    msg = "Should not allow adding duplicate rooms"
    assert_raises(StandardError, msg) {room1.connect_to(room2)}
  end
end
