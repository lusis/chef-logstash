# Encoding: utf-8
default['logstash']['basedir'] = '/opt/logstash'
default['logstash']['user'] = 'logstash'
default['logstash']['uid'] = nil  # set to nil to let system pick
default['logstash']['group'] = 'logstash'
default['logstash']['gid'] = nil  # set to nil to let system pick
default['logstash']['default_version'] = '1.4.0.rc1'
default['logstash']['default_checksum'] = 'b015fa130d589af957c9a48e6f59754f5c0954835abf44bd013547a6b6520e59'
default['logstash']['default_source_url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.rc1.tar.gz'
default['logstash']['default_install_type'] = 'tarball'
default['logstash']['supervisor_gid'] = node['logstash']['group']
default['logstash']['pid_dir'] = '/var/run/logstash'
default['logstash']['create_account'] = true
default['logstash']['join_groups'] = []
default['logstash']['homedir'] = '/var/lib/logstash'

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
when 'rhel'
  default['logstash']['zeromq_packages'] = %w{ zeromq zeromq-devel }
when 'fedora'
  default['logstash']['zeromq_packages'] = %w{ zeromq zeromq-devel }
when 'debian'
  default['logstash']['zeromq_packages'] = %w{ libzmq3-dbg libzmq3-dev libzmq3 }
end

# Logging features
default['logstash']['logging']['rotateFrequency'] = 'daily'
default['logstash']['logging']['maxBackup'] = 10
default['logstash']['logging']['maxSize'] = '10M'
default['logstash']['logging']['useFileSize'] = false

