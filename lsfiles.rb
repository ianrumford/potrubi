#!/usr/bin/jruby

selectMatches = [
                 Regexp.new('\.rb\Z'),
                 Regexp.new('README'),
                 Regexp.new('Rakefile'),
                 Regexp.new('Gemfile'),
                 #Regexp.new('.gemspec\Z'),
                ]

rejectMatches = [
                 Regexp.new('HOLD'),
                 ]

#fileList = `git ls-files`.split("\n")
fileList = `git ls-files`.split("\n").select {|f| selectMatches.any? {|r| r.match(f)}   }


fileList.each {|f| puts("FILE >#{f}<") }
  
