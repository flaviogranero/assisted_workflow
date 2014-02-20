require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.pattern = "spec/**/*_spec.rb"
end

task :console do
  require 'irb'
  require 'irb/completion'
  require 'assisted_workflow'
  require 'assisted_workflow/cli'
  ARGV.clear
  IRB.start
end