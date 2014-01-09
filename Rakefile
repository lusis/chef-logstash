#!/usr/bin/env rake

@cookbook_path = '/tmp/logstash-cookbooks'
@cookbook = "logstash"

desc "install dependencies using Berkshelf"
task :install_deps do
  system("berks install --path=#{@cookbook_path}")
end

desc "Runs foodcritic linter"
task :foodcritic do
  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    sandbox = File.join(File.dirname(__FILE__), %w{tmp foodcritic}, @cookbook)
    prepare_test_sandbox(sandbox)
    
    sh "foodcritic --epic-fail any #{File.dirname(sandbox)}"
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

desc "Runs Strainer"
task :strainer do
  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    sandbox = '/tmp/cookbook_logstash'
    prepare_test_sandbox(sandbox)
    rm_rf '/tmp/strainer'
    gemfile="#{File.dirname(__FILE__)}/test/support/Gemfile"
    puts gemfile
    sh "cd #{sandbox} && BUNDLE_GEMFILE=#{gemfile} bundle exec strainer test --sandbox=/tmp/strainer --cookbooks-path=#{@cookbook_path}"
  else
    puts "WARN: strainer run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

task :default => 'foodcritic'

private

def prepare_test_sandbox(sandbox)
  files = %w{ *.md *.rb attributes definitions files providers Strainerfile .rubocop*
    recipes resources templates spec }

  rm_rf sandbox
  mkdir_p sandbox
  cp_r Dir.glob("{#{files.join(',')}}"), sandbox
  puts "\n\n"
end

begin
  require 'kitchen/rake_tasks'
  Kitchen::RakeTasks.new
rescue LoadError
  puts ">>>>> Kitchen gem not loaded, omitting tasks" unless ENV['CI']
end
