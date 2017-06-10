# Encoding: utf-8

source 'https://api.berkshelf.com' if Gem::Version.new(Berkshelf::VERSION) > Gem::Version.new('3')

metadata

group :integration do
  cookbook 'apt'
  cookbook 'beaver'
  cookbook 'logstash-test', path: 'test/fixtures/cookbooks/logstash-test'
end
