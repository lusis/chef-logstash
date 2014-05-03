# Encoding: utf-8

# source 'https://api.berkshelf.com'

metadata

cookbook 'java'
cookbook 'pleaserun', git: 'https://github.com/paulczar/chef-pleaserun.git'
cookbook 'curl'
cookbook 'ark'

group :test do
  cookbook 'minitest-handler', git: 'git://github.com/btm/minitest-handler-cookbook.git'
  cookbook 'elasticsearch', git: 'git://github.com/elasticsearch/cookbook-elasticsearch.git'
  cookbook 'kibana', git: 'git://github.com/lusis/chef-kibana.git'
end
