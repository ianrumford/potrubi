require "bundler/gem_tasks"
require 'rake/testtask'
require 'yard'

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['test/ts_*.rb']
  #t.test_files = FileList['test/ts_bootstrap_mixins.rb']
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  ##t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  ##t.options = ['--any', '--extra', '--opts'] # optional
end


__END__

Note pattern - ** is recursive

require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "spec/**/*_spec.rb"
end
