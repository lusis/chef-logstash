# Encoding: utf-8
default['logstash']['server']['name']           = 'server'
default['logstash']['server']['home']           = "/opt/logstash/#{node['logstash']['server']['name']}"
default['logstash']['server']['version']        = '1.4.0.rc1'
default['logstash']['server']['source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.rc1.tar.gz'
default['logstash']['server']['checksum']       = 'b015fa130d589af957c9a48e6f59754f5c0954835abf44bd013547a6b6520e59'
default['logstash']['server']['install_method'] = 'tarball'
default['logstash']['server']['config_file']    = 'logstash.conf'
default['logstash']['server']['log_file']       = 'server.log'
default['logstash']['server']['base_config']    = 'server.conf.erb' # set blank if don't want data driven config

default['logstash']['server']['xms']        = '1024M'
default['logstash']['server']['xmx']        = '1024M'
default['logstash']['server']['java_opts']  = ''
default['logstash']['server']['gc_opts']    = '-XX:+UseParallelOldGC'
default['logstash']['server']['ipv4_only']  = false
default['logstash']['server']['debug']      = false
default['logstash']['server']['workers']    = 1
default['logstash']['server']['patterns']   = []

default['logstash']['server']['base_config_cookbook'] = 'logstash'
default['logstash']['server']['config_templates'] = []
default['logstash']['server']['config_templates_cookbook'] = 'logstash'
default['logstash']['server']['config_templates_variables'] = {}

# allow control over the upstart config
default['logstash']['server']['upstart_with_sudo'] = false

default['logstash']['server']['init_method'] = 'native' # native or runit
# roles/flags for various autoconfig/discovery components
default['logstash']['server']['enable_embedded_es'] = true

default['logstash']['server']['inputs'] = []
default['logstash']['server']['filters'] = []
default['logstash']['server']['outputs'] = []

default['logstash']['server']['web']['enable']  = false
default['logstash']['server']['web']['address'] = '0.0.0.0'
default['logstash']['server']['web']['port']    = '9292'

default['logstash']['server']['logrotate']['options'] = %w{ missingok notifempty compress copytruncate }