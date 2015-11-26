# T10::Dungeon

This gem will generate a 10 room dungeon (plus entrance and exit rooms) with
random placements of the rooms. This gem is extracted from
[t10](https://github.com/mbrand12/t10) text adventure game as a gem creation
exercise from a ruby app exercise.

This gem uses [gitflow](https://github.com/petervanderdoes/gitflow-avh) workflow.

## Installation

Add this line to your application's Gemfile:

```ruby

gem 't10-dungeon', git: 'https://github.com/mbrand12/t10-dungeon.git', branch: 'develop'

```

And then execute:

    $ bundle

## Usage

Minimal code example needed for this to work (note that you need to have 10
rooms implemented along with entrance and exit room.. so 12 total :) ):

```ruby

 class Room
   include T10::Dungeon::Traversable

   # Maximum number of doors.
   DOORS = 4

   def initialize
     @doors = {
        east:  [],
        south: [],
        west:  [],
        north: []
     }
   end
 end

 class EntranceRoom < Room

   # Entrance must have at least 2 doors for the dungeon generator to work.
   DOORS = 2

   def initialize
     super

     @has_left =  false
     @has_right = false
     @has_ahead = true
   end

   # room logic...
 end

 class ExitRoom < Room

   # Exit must have 1 door for dungeon generator to work.
   DOORS = 1

  def initialize()
     super

     @has_left = false
     @has_right = false
     @has_ahead = false
   end

   # room logic...
 end

 class SampleRoom < Room

   # Number of doors must correspond to the @has_ flags.
   DOORS = 3

   def initialize
     super

     @has_left = true
     @has_right = false  # If DOORS == 4, @has_right also true.
     @has_ahead = true
   end

   # room logic...
 end


 # To generate dungeon (returns Array<Room>):
 T10::Dungeon.generate(rooms, entrance_room, exit_room)

```
## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

