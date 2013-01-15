# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

###puts "LOAD PATH >#{$LOAD_PATH}<"

require "potrubi/version"

selectMatches = [
                 Regexp.new('\.rb\Z'),
                 Regexp.new('README'),
                 Regexp.new('Rakefile'),
                 Regexp.new('Gemfile'),
                 Regexp.new('.gemspec\Z'),
                ]

rejectMatches = [
                 Regexp.new('HOLD'),
                 Regexp.new('lsfiles.rb')
                 ]

Gem::Specification.new do |s|
  s.name        = "potrubi"
  s.version     = Potrubi::VERSION
  s.authors     = ["Ian Rumford"]
  s.email       = ["ian@rumford.name"]
  s.homepage    = "https://github.com/ianrumford/potrubi"
  s.summary     = %q{Potrubi: plumbing for Ruby}
  s.description = %q{Potrubi: A collection of Ruby mixins for common needs}

  s.rubyforge_project = "potrubi"

  #s.files         = `git ls-files`.split("\n")

  s.files         = `git ls-files`.split("\n").select {|f| selectMatches.any? {|r| r.match(f)} && (! rejectMatches.any? {|r| r.match(f) })  }

  #  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f|
  #  File.basename(f) }
  
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  
  # s.add_development_dependency "yaml"
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
