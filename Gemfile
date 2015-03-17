# Encoding: utf-8

source 'https://rubygems.org'

gem 'berkshelf'

if ENV['CI']
  gem 'serverspec', '>= 2.0'
  gem 'vagrant-wrapper'
  gem 'chef', '>= 11.8'
  gem 'rake', '>= 10.2'
  gem 'rubocop', '>= 0.23'
  gem 'foodcritic', '>= 4.0'
  gem 'chefspec', '>= 4.0'
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'nokogiri', '>= 1.6.4.1'
else
  gem 'chef'
  gem 'rake'
  gem 'rubocop'
  gem 'foodcritic'
  gem 'chefspec'
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'nokogiri'
  unless ENV['RAKE']
    gem 'stove'
    gem 'guard', '>= 2.6'
    gem 'guard-rubocop', '>= 1.1'
    gem 'guard-foodcritic', '>= 1.0.2'
  end
end
