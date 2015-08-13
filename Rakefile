require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:unit) do |task|
  task.pattern = 'spec/unit/*_spec.rb'
  task.rspec_opts = ['--color', '-f documentation']
end

RSpec::Core::RakeTask.new(:integration) do |task|
  task.pattern = 'spec/integration/*_spec.rb'
  task.rspec_opts = ['--color', '-f documentation']
end

task default: :unit
