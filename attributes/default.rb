# Encoding: utf-8

# roles/flags for various search/discovery
default['logstash']['instance']['default']['graphite_role'] = 'graphite_server'
default['logstash']['instance']['default']['graphite_query'] = "roles:#{node['logstash']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['instance']['default']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['instance']['default']['elasticsearch_query'] = "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['instance']['default']['elasticsearch_cluster'] = 'logstash'
default['logstash']['instance']['default']['elasticsearch_ip'] = ''
default['logstash']['instance']['default']['elasticsearch_port'] = ''
default['logstash']['instance']['default']['graphite_ip'] = ''

# Default logstash instance variables
default['logstash']['instance']['default']['basedir'] = '/opt/logstash'
default['logstash']['instance']['default']['user'] = 'logstash'
default['logstash']['instance']['default']['uid'] = nil  # set to nil to let system pick
default['logstash']['instance']['default']['group'] = 'logstash'
default['logstash']['instance']['default']['gid'] = nil  # set to nil to let system pick
default['logstash']['instance']['default']['supervisor_gid'] = node['logstash']['group']
default['logstash']['instance']['default']['pid_dir'] = '/var/run/logstash'
default['logstash']['instance']['default']['create_account'] = true
default['logstash']['instance']['default']['join_groups'] = []
default['logstash']['instance']['default']['homedir'] = '/var/lib/logstash'

default['logstash']['instance']['default']['name']           = 'server'
default['logstash']['instance']['default']['home']           = "/opt/logstash/#{node['logstash']['instance']['default']['name']}"
default['logstash']['instance']['default']['version']        = '1.4.0.rc1'
default['logstash']['instance']['default']['source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.rc1.tar.gz'
default['logstash']['instance']['default']['checksum']       = 'b015fa130d589af957c9a48e6f59754f5c0954835abf44bd013547a6b6520e59'
default['logstash']['instance']['default']['install_type']   = 'tarball'
default['logstash']['instance']['default']['log_file']       = 'server.log'
default['logstash']['instance']['default']['base_config']    = 'server.conf.erb' # set blank if don't want data driven config

default['logstash']['instance']['default']['xms']        = '1024M'
default['logstash']['instance']['default']['xmx']        = '1024M'
default['logstash']['instance']['default']['java_opts']  = ''
default['logstash']['instance']['default']['gc_opts']    = '-XX:+UseParallelOldGC'
default['logstash']['instance']['default']['ipv4_only']  = false
default['logstash']['instance']['default']['debug']      = false
default['logstash']['instance']['default']['workers']    = 1

default['logstash']['instance']['default']['patterns_templates_cookbook'] = 'logstash'
default['logstash']['instance']['default']['patterns_templates']          = {}

default['logstash']['instance']['default']['base_config_cookbook']       = 'logstash'
default['logstash']['instance']['default']['config_file']                = ''
default['logstash']['instance']['default']['config_templates']           = {}
default['logstash']['instance']['default']['config_templates_cookbook']  = 'logstash'
default['logstash']['instance']['default']['config_templates_variables'] = {}

# allow control over the upstart config
default['logstash']['instance']['default']['upstart_with_sudo'] = false

default['logstash']['instance']['default']['init_method'] = 'native' # native or runit
# roles/flags for various autoconfig/discovery components
default['logstash']['instance']['default']['enable_embedded_es'] = true

default['logstash']['instance']['default']['inputs'] = []
default['logstash']['instance']['default']['filters'] = []
default['logstash']['instance']['default']['outputs'] = []

default['logstash']['instance']['default']['web']['enable']  = false
default['logstash']['instance']['default']['web']['address'] = '0.0.0.0'
default['logstash']['instance']['default']['web']['port']    = '9292'

default['logstash']['instance']['default']['logrotate']['options'] = %w(missingok notifempty compress copytruncate)

# Logging features
default['logstash']['instance']['default']['logging']['rotateFrequency'] = 'daily'
default['logstash']['instance']['default']['logging']['maxBackup'] = 10
default['logstash']['instance']['default']['logging']['maxSize'] = '10M'
default['logstash']['instance']['default']['logging']['useFileSize'] = false
