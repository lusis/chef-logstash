# Encoding: utf-8

namespace :style do
  task :rubocop do
    sh "#{run_cmd} rubocop"
  end

  task :foodcritic do
    sh "#{run_cmd} foodcritic ."
  end
end

desc 'Run all style checks'
task style: ['style:foodcritic', 'style:rubocop']

namespace :integration do
  task :kitchen do
    sh "#{run_cmd} kitchen test"
  end
end

task integration: ['integration:kitchen']

namespace :unit do
  task :chefspec do
    sh "#{run_cmd} rspec test/unit/spec"
  end
end

desc 'Run all unit tests'
task unit: ['unit:chefspec']
task spec: ['unit:chefspec']

# Run all tests
desc 'Run all tests'
task test: ['style', 'unit', 'integration']

# The default rake task should run style and unit tests
desc 'Install required Gems and Cookbook then run all tests'
task default: ['style', 'unit']

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
end

private

def run_cmd
  puts 'bundle exec'
end
