require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |config|
  ENV['COVERAGE'] = "true"
end

task :default => :spec
