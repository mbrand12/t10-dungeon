# Sample implementations for testing, with a few helper methods.
class Room
  include T10::Dungeon::Traversable

  DOORS = 4

  @rooms = []
  class << self
    attr_reader :rooms
  end

  def self.inherited(room_implementations)
      @rooms << room_implementations
    end

  attr_reader :doors

  def initialize
    @doors = {
      east:  [],
      south: [],
      west:  [],
      north: []
    }
  end

  # tests if the connections go both ways.
  def test_connections
    @doors.all? do |k, v|
      v[-1] ? v[-1].leads_to?(self.class, k): true
    end
  end

  protected

  def leads_to?(room_class, room_crest)
    @doors.any? do |k, v|
      v[-1].class == room_class && k == orient(room_crest)
    end
  end

  def orient(room_crest)
    case room_crest
    when :east
      :west
    when :south
      :north
    when :west
      :east
    when :north
      :south
    end
  end
end


class EntranceRoom < Room
  DOORS = 2
  def initialize
    super
    @has_left = false
    @has_right = false
    @has_ahead = true
  end
end

class ExitRoom < Room
  DOORS = 1
  def initialize
    super
    @has_left = false
    @has_right = false
    @has_ahead = false
  end
end


class R11 < Room
  DOORS = 1
  def initialize
    super
    @has_left  = false
    @has_right = false
    @has_ahead = false
  end
end

class R12 < Room
  DOORS = 1
  def initialize
    super
    @has_left  = false
    @has_right = false
    @has_ahead = false
  end
end

class R13 < Room
  DOORS = 1
  def initialize
    super
    @has_left  = false
    @has_right = false
    @has_ahead = false
  end
end

class R14 < Room
  DOORS = 1
  def initialize
    super
    @has_left  = false
    @has_right = false
    @has_ahead = false
  end
end

class R21 < Room
  DOORS = 2
  def initialize
    super
    @has_left  = true
    @has_right = false
    @has_ahead = false
  end
end

class R22 < Room
  DOORS = 2
  def initialize
    super
    @has_left  = false
    @has_right = true
    @has_ahead = false
  end
end

class R23 < Room
  DOORS = 2
  def initialize
    super
    @has_left  = false
    @has_right = false
    @has_ahead = true
  end
end

class R31 < Room
  DOORS = 3
  def initialize
    super
    @has_left  = true
    @has_right = true
    @has_ahead = false
  end
end

class R32 < Room
  DOORS = 3
  def initialize
    super
    @has_left  = true
    @has_right = false
    @has_ahead = true
  end
end

class R4 < Room
  DOORS = 4
  def initialize
    super
    @has_left  = true
    @has_right = true
    @has_ahead = true
  end
end
