module T10
  module Dungeon
    # The methods in this module are used to connect a Room to another Room
    # (making them traversable) while ensuring that the connection goes both
    # ways and takes care of internal and external orientations. The connection
    # is assigned to the instance variable @door, which a class that includes
    # this module must declare within the constructor (the class also must
    # include @has_left, @has_right and @has_ahead instance variables within
    # the constructor)
    #
    # Each room can have up to 4 doors, each door takes one cardinal direction
    # and requires that the room connected to that door follows that logic. In
    # other words if one exits via the east door it will come in the next room
    # via the west entrance.
    #
    # An origin door leads to the room that leads to the entrance room (the
    # first room in the dungeon). The origin door provides the means of
    # internal orientation without being dependent on the external orientation.
    # The narration in the room should always be made with that in mind (write
    # the description as if the Hero is always with his back turned on the
    # origin door).
    #
    # So regardless of external orientation of the room (east, west, north,
    # south) the internal orientation will always be the same. That way if a
    # specific room always has a door on the left it will have it regardless of
    # its external orientation (or rotation).
    #
    # An example of the @doors instance variable that holds the connections:
    #
    #     # The keys are the external orientation.
    #     # The second value is the internal rotation that is relative to the
    #     # :origin. The :ahead will always be the opposite cardinal direction
    #     # from the : origin, same with :to_right and :to_left. So if the
    #     # :origin is :west the :ahead is :east.
    #     #
    #     # The third value is the reference to the instance of the room the
    #     # door leads to. Weather the value gets assigned here is dependent on
    #     # weather the room has that door via the @has_left, @has_right, and
    #     # @has_ahead boolean instance variables of the class that includes
    #     # this module.
    #
    #
    #     # before connecting using {connect_to}
    #     @doors = {
    #        east:   [values],
    #        south:  [values],
    #        west:   [values],
    #        north:  [values]
    #     }
    #     # after
    #     @doors = {
    #        east:   [values, :ahead, nil],
    #        south:  [values, :to_right, nil],
    #        west:   [values, :origin, origin_room],
    #        north:  [values, :to_left, nil]
    #     }
    #
    # These methods are used only when generating the dungeon, and should only
    # be used by the dungeon generator.
    module Traversable
      # Connects one room to another where the receiver is the origin room. If
      # the `room` parameter is nil then the external orientation is randomly
      # selected (the only case for this is for the entrance room).
      #
      # This is the only method that should be called in order to connect the
      # rooms.
      #
      # First the room (parameter) in question is added to the @doors of the
      # origin room (receiver), based on weather the room has any empty doors to
      # fill see {Traversable#add_door_leading_to} for more details.
      #
      # Then the origin door is added to the room's @door instance variable
      # and the variable internal orientation is set based on the origin room's
      # crest leading to that room see {Traversable#add_origin_door} for more
      # details.
      #
      # @param room [Room] The room that gets assigned its origin door.
      # @return [Room] the room that was assigned its origin door.
      def connect_to(room = nil)
        return add_origin_door unless room

        crest_to_room = add_door_leading_to(room)
        @doors[crest_to_room][-1].add_origin_door(self, crest_to_room)
      end

      protected

      # Method adds the origin door to the room (receiver) based on the provided
      # crest from the origin room (parameter). The method is called in
      # {Traversable#connect_to}.
      #
      # The method raises an exception if the room first gets an origin door
      # before the origin room adds the room to the @door. This prevents from
      # the room having an origin door to a room which do not have the reference
      # to that room (in case the origin room has it slots full with other rooms
      # for example).
      #
      # If the origin room is not provided the method samples a direction
      # from list and setups the internal orientation based on that. Otherwise
      # it will use the crest from the origin room leading to room (receiver).
      #
      # @param origin_room [Room] The room that leads to receiver.
      # @param crest_to_room [Symbol] The external orientation leading to
      #                               receiver.
      # @raise [StandardError] if the origin room doesn't lead to the receiver.
      # @return [Room] the receiver.
      def add_origin_door(origin_room = nil, crest_to_room = nil)
        if origin_room && !crest_to_room
          fail StandardError,
               "#{origin_room} should lead to this (#{self.class} room) " \
               "before #{self.class} can lead to #{origin_room}"
        end

        unless origin_room
          crest_to_room = [:east, :south, :west, :north].sample
        end

        case crest_to_room
        when :east
          @doors = {
            east:  @doors[:east].push(:ahead, nil),
            south: @doors[:south].push(:to_right, nil),
            west:   @doors[:west].push(:origin, origin_room),
            north:  @doors[:north].push(:to_left, nil)
          }
        when :south
          @doors = {
            east:  @doors[:east].push(:to_left, nil),
            south: @doors[:south].push(:ahead, nil),
            west:   @doors[:west].push(:to_right, nil),
            north:  @doors[:north].push(:origin, origin_room)
          }
        when :west
          @doors = {
            east:  @doors[:east].push(:origin, origin_room),
            south: @doors[:south].push(:to_left, nil),
            west:   @doors[:west].push(:ahead, nil),
            north:  @doors[:north].push(:to_right, nil)
          }
        when :north
          @doors = {

            east:  @doors[:east].push(:to_right, nil),
            south: @doors[:south].push(:origin, origin_room),
            west:   @doors[:west].push(:to_left, nil),
            north:  @doors[:north].push(:ahead, nil)
          }
        end
        self
      end

      # This method adds the room (parameter) to the @doors of the receiver
      # (origin room). This method is called by the {Traversable#connect_to}.
      #
      # This method does not handle exceptions, it requires client to know
      # the total number of available doors and the number of occupied doors by
      # checking the subclass DOORS constant.
      #
      # After adding the method in the free slot of the @doors determined by the
      # @has_left, @has_right and @has_ahead (as well as the DOORS constant) of
      # the Room, the method returns the crest (or external orientation) of the
      # door that leads to the room (parameter).
      #
      # @param room [Room] A room to be added to @doors of the origin_room.
      # @raise [StandardError] if there are more than one room of the same class.
      # @raise [StandardError] if all doors are occupied.
      # @return [Symbol] The crest of the door leading to room (parameter)
      def add_door_leading_to(room)
        if @doors.find { |_, v| v[-1].class == room.class }
          fail StandardError, "Duplicate rooms not allowed!"
        end

        left_crest  = get_crest_from_relative(:to_left) if @has_left
        right_crest = get_crest_from_relative(:to_right) if @has_right
        ahead_crest = get_crest_from_relative(:ahead) if @has_ahead

        case
        # does the room have a door to the left and is that door not occupied?
        when @has_left && @doors[left_crest][-1].nil?
          @doors[left_crest][-1] = room
          left_crest
        when @has_right && @doors[right_crest][-1].nil?
          @doors[right_crest][-1] = room
          right_crest
        when @has_ahead && @doors[ahead_crest][-1].nil?
          @doors[ahead_crest][-1] = room
          ahead_crest
        else
          fail StandardError,
               "All doors for room #{self.class} occupied." \
               " #{room.class} not added."
        end
      end

      private

      def get_crest_from_relative(orientation)
        @doors.find { |_, v| v[-2] == orientation }[0]
      end
    end
  end
end
