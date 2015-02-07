
# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

###puts "LOAD PATH >#{$LOAD_PATH}<"

require "potrubi/version"

selectMatches = [
                 Regexp.new('\.rb\Z'),
                 Regexp.new('README'),
                 Regexp.new('LICENCE'),
                ]

rejectMatches = [
                 Regexp.new('HOLD'),
                 Regexp.new('lsfiles.rb'),
                 Regexp.new('Rakefile'),
                 Regexp.new('Gemfile'),
                 Regexp.new('.gemspec\Z'),
                 ]

Gem::Specification.new do |s|
  
  s.name        = "potrubi"
  s.version     = Potrubi::VERSION
  s.authors     = ["Ian Rumford"]
  s.email       = ["ian@rumford.name"]
  s.homepage    = "https://github.com/ianrumford/potrubi"
  s.summary     = %q{Potrubi: Plumbing for Ruby}
  s.description = %q{Potrubi: A collection of Ruby mixins for common needs}

  s.rubyforge_project = "potrubi"

  #s.files         = `git ls-files`.split("\n")

  s.files         = `git ls-files`.split("\n").select {|f| selectMatches.any? {|r| r.match(f)} && (! rejectMatches.any? {|r| r.match(f) })  }

  s.executables = []
  
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 1.9.3'

end

