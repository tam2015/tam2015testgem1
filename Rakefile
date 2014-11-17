require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

# Default directory to look in is `/specs`
# Run with `rake spec`
RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = ['--color']
end

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -r meli.rb"
end

ENV["RACK_ENV"] = "test"

task :default => :spec
