metadata

# Don't need to list cookbooks in here that are also listed in the metadata depends statements
# unless there are specific overrides like git repo or version are needed

cookbook 'rabbitmq', git: 'git://github.com/opscode-cookbooks/rabbitmq.git'
cookbook 'yumrepo', git: 'git://github.com/bryanwb/cookbook-yumrepo.git'

group :test do
    cookbook 'minitest-handler', git: 'git://github.com/btm/minitest-handler-cookbook.git'
    cookbook 'elasticsearch', git: 'git://github.com/elasticsearch/cookbook-elasticsearch.git'
end