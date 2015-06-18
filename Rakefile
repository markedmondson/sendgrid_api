require 'bundler/gem_tasks'
require 'appraisal'
require 'rspec/core/rake_task'

desc 'Default: run library specs.'
task :default => [:spec]

desc "Run library specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = ["./spec/**/*_spec.rb"]
end
