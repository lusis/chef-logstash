# Encoding: utf-8

source 'https://api.berkshelf.com' if Gem::Version.new(Berkshelf::VERSION) > Gem::Version.new('3')

metadata

cookbook 'java'
cookbook 'curl'
cookbook 'ark'

cookbook 'pleaserun', git: 'https://github.com/paulczar/chef-pleaserun.git'

group :test do
  cookbook 'minitest-handler', git: 'https://github.com/btm/minitest-handler-cookbook.git'
  cookbook 'elasticsearch', git: 'https://github.com/elasticsearch/cookbook-elasticsearch.git'
  cookbook 'kibana', git: 'https://github.com/lusis/chef-kibana.git'
end
