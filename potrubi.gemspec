# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path("../lib", __FILE__)

puts "LOAD PATH >#{$LOAD_PATH}<"

require "potrubi/version"

Gem::Specification.new do |s|
  s.name        = "potrubi"
  s.version     = Potrubi::VERSION
  s.authors     = ["Ian Rumford"]
  s.email       = ["ian@rumford.name"]
  s.homepage    = ""
  s.summary     = %q{Potrubi: plumbing for Ruby}
  s.description = %q{Potrubi: A collection of mixins for Common Ruby needs}

  s.rubyforge_project = "potrubi"

  #s.files         = `git ls-files`.split("\n")
  s.files         = `git ls-files`.split("\n").select {|f| f.match(/\.rb\Z/) }
#  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
#  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f|
  #  File.basename(f) }
  
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  
  #s.add_development_dependency "yaml"
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
