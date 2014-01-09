metadata
cookbook 'logrotate'
cookbook 'minitest-handler', git: 'git://github.com/btm/minitest-handler-cookbook.git'
cookbook 'elasticsearch', git: 'git@github.com:Tapjoy/elasticsearch-cookbook.git'
cookbook 'discovery', git: 'git@github.com:Tapjoy/discovery-cookbook.git'

%w{ apt java build-essential runit rabbitmq }.each do |cookbook|
  cookbook cookbook, git: 'git@github.com:Tapjoy/chef.git',
    rel: "cookbooks/#{cookbook}"
end
