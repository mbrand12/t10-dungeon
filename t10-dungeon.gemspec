# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 't10/dungeon/version'

Gem::Specification.new do |spec|
  spec.name          = "t10-dungeon"
  spec.version       = T10::Dungeon::VERSION
  spec.authors       = ["mbrand12"]
  spec.email         = ["mbrand12.dump@gmail.com"]

  spec.summary       = %q{ A gem for randomly generating a dungeon of rooms. }
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/mbrand12/t10-dungeon"
  spec.license       = "MIT"

  spec.files         = `git ls-files lib -z`.split("\x0")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
end
