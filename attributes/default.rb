default['logstash']['basedir'] = '/opt/logstash'
default['logstash']['user'] = 'logstash'
default['logstash']['group'] = 'logstash'
default['logstash']['supervisor_gid'] = node['logstash']['group']
default['logstash']['pid_dir'] = '/var/run/logstash'
default['logstash']['create_account'] = true
default['logstash']['join_groups'] = []

# roles/flags for various search/discovery
default['logstash']['graphite_role'] = 'graphite_server'
default['logstash']['graphite_query'] = "roles:#{node['logstash']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['elasticsearch_query'] = "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_cluster'] = 'logstash'
default['logstash']['elasticsearch_ip'] = ''
default['logstash']['elasticsearch_port'] = ''
default['logstash']['graphite_ip'] = ''

default['logstash']['patterns'] = {}
default['logstash']['install_zeromq'] = false
default['logstash']['install_rabbitmq'] = false

case node['platform_family']
when "rhel"
  default['logstash']['zeromq_packages'] = [ "zeromq",  "zeromq-devel"]
when "debian"
  default['logstash']['zeromq_packages'] = [ "zeromq",  "libzmq-dev"]
end

# Logging features
default['logstash']['logging']['rotateFrequency'] = "daily"
default['logstash']['logging']['maxBackup'] = 10
default['logstash']['logging']['maxSize'] = "10M"
default['logstash']['logging']['useFileSize'] = false


