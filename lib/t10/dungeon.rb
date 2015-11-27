require "t10/dungeon/version"
require "t10/dungeon/traversable"

module T10
  # The dungeon class sole responsibility is to create an array of properly
  # connected rooms following a specific algorithm.
  #
  # A Room is any class that includes {Traversable} module. Each room must also
  # have a `DOORS` integer constant which currently must be equal or less than 4.
  # The room must also have `@doors` hash instance variable, as well as
  # `@has_left`, `@has_right`, `@has_ahead` boolean instance variables which must
  # correspond to DOORS constant (meaning that if the room has one door, all
  # the `@has_` values must be false, if it has two doors, one variable must be
  # true and other false etc.)
  #
  # Currently only 4 types of rooms are supported. Rooms with one door are
  # called `door_1 types`, with two `door_2 types` etc.
  #
  # In order for algorithm to work a specific number of each types much be
  # sampled from the total number of the rooms of that type. That number is
  # defined in {ROOM_TYPE_LIMIT}. Currently there must be 4 rooms of door_1
  # type, 3 rooms of door_2 type etc.
  #
  # Then a room is sampled from all the types following some rules (like the
  # first room must not be door_1 type, and if there are door_2, door_3 or
  # door_4 types available the room must not have all the doors leading to
  # type_1 room etc.) and added to the list of rooms.
  #
  # Then for that room, based on the available doors, the number of rooms are
  # sampled (also following specific rules) and connected to the origin room (see
  # {Traversable} for a clarification on origin rooms). Once the room
  # has its doors occupied the algorithm moves to the next room in the list and
  # does the same until all the rooms from the @rooms_by_type are sampled.
  #
  # Example of minimal requirement for a classes to be a "room":
  #
  #     class Room
  #       include T10::Dungeon::Traversable
  #
  #       def initialize
  #         @doors = {
  #            east:  [],
  #            south: [],
  #            west:  [],
  #            north: []
  #         }
  #       end
  #     end
  #
  #     class EntranceRoom < Room
  #       DOORS = 2
  #
  #       def initialize
  #         super
  #
  #         @has_left = true
  #         @has_right = false
  #         @has_ahead = false
  #       end
  #
  #       # room logic...
  #     end
  #
  #     class ExitRoom < Room
  #       DOORS = 1
  #
  #       def initialize()
  #         super
  #
  #         @has_left = false
  #         @has_right = false
  #         @has_ahead = false
  #       end
  #
  #       # room logic...
  #     end
  #
  #     class SampleRoom < Room
  #       DOORS = 3
  #
  #       def initialize
  #         super
  #
  #         @has_left = true
  #         @has_right = false
  #         @has_ahead = true
  #       end
  #
  #       # room logic...
  #     end
  module Dungeon
    # The max number of rooms needed of a certain type.
    ROOM_TYPE_LIMIT = [0, 4, 3, 2, 1]

    @rooms_by_type = {
      door_1: [],
      door_2: [],
      door_3: [],
      door_4: []
    }

    @dungeon_rooms = []

    @entrance_room = nil
    @exit_room = nil

    # Generates a list of rooms and connects them properly.
    #
    # First @rooms_by_type is populated from the list of all rooms from `rooms`
    # parameter.
    #
    # Example:
    #
    #     @rooms_by_type = {
    #       door_1: [ArmorRoom, SimpleRoom, EmptyRoom, BossRoom],
    #       door_2: [TrapRoom, JungleRoom, MazeRoom],
    #       door_3: [MachineRoom, HiddenDoorRoom],
    #       door_4: [HallRoom]
    #     }
    #
    # After all the rooms are placed in their respective type the rooms are
    # shuffled within their type.
    #
    # Then a `entrance_room` is created, its origin room set to nil and added
    # to the list of generated rooms.
    #
    # Rooms are then sampled based on the current room (and its door limit)
    # following specific rules. When the rooms are sampled and properly
    # connected they are added to the `@dungeon_rooms` list. Once the current
    # room has its door occupied the list goes to the next room and does all
    # this.
    #
    # The last room connected is always the exit_room which ensures that the
    # exit room will not show near the beginning, but due to the random nature
    # of the dungeon it won't always be the furthest room.
    #
    # It there are more rooms for sampling than the needed they are ignored,
    # this allows that if there are 10 type_1 rooms are present only 4 will be
    # selected making every playtrough different.
    # @param rooms [Array<Class>] An array of rooms.
    # @param entrance_room [Class] Dedicated entrance room (which must have
    #   two doors).
    # @param exit_room [Class] Dedicated exit room (which must have one door).
    # @return [Array<Room>] returns a array of sampled rooms properly connected.
    def self.generate(rooms, entrance_room, exit_room)

      @entrance_room = entrance_room
      @exit_room = exit_room

      check(rooms)
      populate_types_and_shuffle(rooms)

      @dungeon_rooms = [@entrance_room.new]
      @dungeon_rooms[0].prepare_entrance!

      @dungeon_rooms.each do |current_room|
        next if current_room.class::DOORS == 1

        sample_rooms_for(current_room).each do |sampled_room|
          @dungeon_rooms << current_room.connect_to(sampled_room.new)
        end
      end
      @dungeon_rooms
    end

    private

    def self.check(rooms)
      unless @entrance_room::DOORS == 2 && @exit_room::DOORS == 1
        raise StandardError,
              "Entrance room must have two doors and exit must have one door!"
      end
      unless rooms.uniq.length == rooms.length
        raise StandardError, "No duplicate classes allowed!"
      end
      rooms.each do |room|
        unless room.included_modules.include?(T10::Dungeon::Traversable)
          raise StandardError, "Class #{room} did not include Traversable module"
        end
        unless room.const_defined? :DOORS
          raise StandardError, "Class #{room} must have DOORS constant!"
        end
      end
    end

    def self.populate_types_and_shuffle(rooms)

      rooms -= [@entrance_room, @exit_room]

      @rooms_by_type.each do |k, _|
        @rooms_by_type[k] =
          rooms.select { |r| r::DOORS == k.slice(5).to_i }
        @rooms_by_type[k] =
          @rooms_by_type[k].shuffle.slice(0, ROOM_TYPE_LIMIT[k.slice(5).to_i])
      end

      if ROOM_TYPE_LIMIT.inject(:+) != number_of_rooms
        fail StandardError,
          "Number of rooms for generating must be the same as room type limit!"
      end
    end

    def self.number_of_rooms
      @rooms_by_type.map { |_, v| v.size }.inject(:+)
    end

    def self.sample_rooms_for(origin_room)
      room_1_limit = origin_room.class::DOORS - 2
      number_of_rooms_to_sample = origin_room.class::DOORS - 1

      sampled_rooms = []

      number_of_rooms_to_sample.times do
        if all_the_rooms_but_1rooms_are_sampled?
          room_1_limit += 1
        end

        permitted_room_types = @rooms_by_type.select { |_, v| !v.empty? }.keys

        if permitted_room_types.include?(:door_1) &&
          ( !dungeon_has_3room_or_4room_sampled? || room_1_limit < 1 )

          permitted_room_types.delete(:door_1)
        end

        sampled_room_type = permitted_room_types.sample

        if sampled_room_type == :door_1
          room_1_limit -= 1
        end

        if sampled_room_type
          sampled_rooms << @rooms_by_type[sampled_room_type].shift
        else
          sampled_rooms << @exit_room
        end
      end
      sampled_rooms
    end

    def self.dungeon_has_3room_or_4room_sampled?
      @dungeon_rooms.any? do |dungeon_room|
        room_doors = dungeon_room.class::DOORS
        room_doors == 3 || room_doors == 4
      end
    end

    def self.all_the_rooms_but_1rooms_are_sampled?
      @rooms_by_type.all? { |k, v| k == :door_1 ? true : v.empty? }
    end
  end
end
