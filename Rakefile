#!/usr/bin/env rake
# Encoding: utf-8

@cookbook_path = '/tmp/logstash-cookbooks'
@cookbook = 'logstash'
@gemfile = "#{File.dirname(__FILE__)}/test/support/Gemfile"

desc 'install dependencies using Berkshelf'
task :install_deps do
  install_deps
end

desc 'Runs foodcritic linter'
task :foodcritic do
  if Gem::Version.new('1.9.2') <= Gem::Version.new(RUBY_VERSION.dup)
    sandbox = File.join(File.dirname(__FILE__), %w{tmp foodcritic}, @cookbook)
    prepare_test_sandbox(sandbox)

    sh "foodcritic --epic-fail any #{File.dirname(sandbox)}"
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

desc 'Runs Strainer'
task :strainer do
  if Gem::Version.new('1.9.2') <= Gem::Version.new(RUBY_VERSION.dup)
    # sandbox = '/tmp/cookbook_logstash'
    # prepare_test_sandbox(sandbox)
    # rm_rf '/tmp/strainer'
    install_deps
    # puts gemfile
    puts "BUNDLE_GEMFILE=#{@gemfile} bundle exec strainer test --sandbox=/tmp/strainer --cookbooks-path=#{@cookbook_path}"
    system({ 'BUNDLE_GEMFILE' => @gemfile }, "bundle exec strainer test --sandbox=/tmp/strainer --cookbooks-path=#{@cookbook_path}")
  else
    puts "WARN: strainer run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

desc 'Runs Test Kitchen'
task :kitchen do
  begin
    require 'kitchen/rake_tasks'
    Kitchen::RakeTasks.new
  rescue LoadError
    puts '>>>>> Kitchen gem not loaded, omitting tasks' unless ENV['CI']
  end
  if Gem::Version.new('1.9.2') <= Gem::Version.new(RUBY_VERSION.dup)
    install_deps
    system({ 'BUNDLE_GEMFILE' => @gemfile }, 'bundle exec kitchen test --destroy=always')
  end
end

task default: 'strainer'

private

def install_deps
  puts "BUNDLE_GEMFILE=#{@gemfile} bundle exec berks install --path=#{@cookbook_path}"
  system({ 'BUNDLE_GEMFILE' => @gemfile }, "bundle exec berks install --path=#{@cookbook_path}")
end

private

def prepare_test_sandbox(sandbox)
  files = %w{ *.md *.rb attributes definitions files providers Strainerfile .rubocop*
              recipes resources templates test/integration test/serverspec }

  rm_rf sandbox
  mkdir_p sandbox
  cp_r Dir.glob("{#{files.join(',')}}"), sandbox
  puts "\n\n"
end
