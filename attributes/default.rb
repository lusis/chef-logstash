# Encoding: utf-8

# roles/flags for various search/discovery
default['logstash']['graphite_role'] = 'graphite_server'
default['logstash']['graphite_query'] = "roles:#{node['logstash']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['elasticsearch_query'] = "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_cluster'] = 'logstash'
default['logstash']['elasticsearch_ip'] = ''
default['logstash']['elasticsearch_port'] = ''
default['logstash']['graphite_ip'] = ''

# Default logstash instance variables
default['logstash']['default']['basedir'] = '/opt/logstash'
default['logstash']['default']['user'] = 'logstash'
default['logstash']['default']['uid'] = nil  # set to nil to let system pick
default['logstash']['default']['group'] = 'logstash'
default['logstash']['default']['gid'] = nil  # set to nil to let system pick
default['logstash']['default']['supervisor_gid'] = node['logstash']['group']
default['logstash']['default']['pid_dir'] = '/var/run/logstash'
default['logstash']['default']['create_account'] = true
default['logstash']['default']['join_groups'] = []
default['logstash']['default']['homedir'] = '/var/lib/logstash'

default['logstash']['default']['name']           = 'server'
default['logstash']['default']['home']           = "/opt/logstash/#{node['logstash']['default']['name']}"
default['logstash']['default']['version']        = '1.4.0.rc1'
default['logstash']['default']['source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.rc1.tar.gz'
default['logstash']['default']['checksum']       = 'b015fa130d589af957c9a48e6f59754f5c0954835abf44bd013547a6b6520e59'
default['logstash']['default']['install_type']   = 'tarball'
default['logstash']['default']['log_file']       = 'server.log'
default['logstash']['default']['base_config']    = 'server.conf.erb' # set blank if don't want data driven config

default['logstash']['default']['xms']        = '1024M'
default['logstash']['default']['xmx']        = '1024M'
default['logstash']['default']['java_opts']  = ''
default['logstash']['default']['gc_opts']    = '-XX:+UseParallelOldGC'
default['logstash']['default']['ipv4_only']  = false
default['logstash']['default']['debug']      = false
default['logstash']['default']['workers']    = 1

default['logstash']['default']['patterns_templates_cookbook'] = 'logstash'
default['logstash']['default']['patterns_templates']          = {}

default['logstash']['default']['base_config_cookbook']       = 'logstash'
default['logstash']['default']['config_file']                = ''
default['logstash']['default']['config_templates']           = {}
default['logstash']['default']['config_templates_cookbook']  = 'logstash'
default['logstash']['default']['config_templates_variables'] = {}

# allow control over the upstart config
default['logstash']['default']['upstart_with_sudo'] = false

default['logstash']['default']['init_method'] = 'native' # native or runit
# roles/flags for various autoconfig/discovery components
default['logstash']['default']['enable_embedded_es'] = true

default['logstash']['default']['inputs'] = []
default['logstash']['default']['filters'] = []
default['logstash']['default']['outputs'] = []

default['logstash']['default']['web']['enable']  = false
default['logstash']['default']['web']['address'] = '0.0.0.0'
default['logstash']['default']['web']['port']    = '9292'

default['logstash']['default']['logrotate']['options'] = %w(missingok notifempty compress copytruncate)

# Logging features
default['logstash']['default']['logging']['rotateFrequency'] = 'daily'
default['logstash']['default']['logging']['maxBackup'] = 10
default['logstash']['default']['logging']['maxSize'] = '10M'
default['logstash']['default']['logging']['useFileSize'] = false