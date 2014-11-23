# Encoding: utf-8

source 'https://api.berkshelf.com' if Gem::Version.new(Berkshelf::VERSION) > Gem::Version.new('3')

metadata

group :test do
  cookbook 'elasticsearch', git: 'https://github.com/elasticsearch/cookbook-elasticsearch.git'
  cookbook 'kibana', git: 'https://github.com/lusis/chef-kibana.git'
  cookbook 'beaver'
end
