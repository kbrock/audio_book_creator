require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |opt|
  (opt.ruby_opts ||= []) << "-Ispec"
end

task :default => :spec
