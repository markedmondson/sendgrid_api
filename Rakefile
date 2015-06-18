require 'bundler/gem_tasks'
require 'appraisal'
require 'rspec/core/rake_task'

desc 'Default: run library specs.'
task :default => [:spec]

desc "Run library specs"
RSpec::Core::RakeTask.new do |t|
  t.pattern = ["./spec/**/*_spec.rb"]
end

namespace :spec do
  desc "Run performance specs"
  RSpec::Core::RakeTask.new(:performance) do |t|
    t.rspec_opts = "--tag performance"
    t.pattern    = ["./spec/**/*_spec.rb"]
  end
end
