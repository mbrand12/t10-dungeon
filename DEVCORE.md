#T10-dungeon Development Diary

## Motivation

After making a text-adventure ruby program the next task was to extract a
interesting part of that program (namely the dungeon generator) as a gem, and
use that to learn more about gems, and how they work.

## Observations

### Intricacies of gem activation

Creating a gem was made easy with [bundler](http://bundler.io/)'s `bundle gem
t10-dungeon` command, but using it in [T10](https://github.com/mbrand12/t10)
was much harder than it seemed.

First of all I had problems with making the needed required properly, one of
the reasons for that not working properly was the way the files where
requireable in the `t10-dungeon.gemspec`.

Namely the `spec.files` uses a `$ git lf-files` in order to list the files
and since I haven't added the new files (`dungeon/generator.rb` and
`dungeon.traversable.rb`) via `$ git add -A` it didn't register.

The second problem was the need to use `require 'bundle/setup'` where for the
other gems like `pry` and `minitest` I didn't have to use that command, and
since I wanted to emulate other gems that needed to be changed.

The problem was that I used that gem locally via `gem 't10-dungeon', :path =>
'path'` in the `Gemfile`.

The reason other gems are just able to be required without being loaded to the
path with `require "bundler/setup"` is that RubyGems overrides the
`Kernel.require` method searching the installed gems for the file needed.

So the solution (localy) was to build gem using `$ gem build` and then
locally installing that gam with `gem install path/to/t10-dungeon.gem`. You
can read more about the about gem activation
[here](http://erik.hollensbe.org/2013/05/11/gem-activation-and-you/).

The third layer is that when the gem is not hosted on RubyGems instead of
being installed to `vendor/gems` it will be installed to
`vendor/bundler/gems/` making it unable to be required by the RubyGems
overridden `Kernel.require` so again `require bundler/setup` must be used.
