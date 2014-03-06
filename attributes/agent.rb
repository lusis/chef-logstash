# Encoding: utf-8
default['logstash']['agent']['version'] = '1.3.3'
default['logstash']['agent']['log_file'] = '/var/log/logstash/agent.log'
default['logstash']['agent']['source_url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.3.3-flatjar.jar'
default['logstash']['agent']['checksum'] = 'a83503bd2aa32e1554b98f812d0b411fbc5f7b6b21cebb48b7d344474f2dfc6d'
default['logstash']['agent']['install_method'] = 'jar' # Either `source` or `jar`
default['logstash']['agent']['home'] = "#{node['logstash']['basedir']}/agent"
default['logstash']['agent']['patterns_dir'] = 'etc/patterns'
default['logstash']['agent']['config_dir'] = 'etc/conf.d'
default['logstash']['agent']['config_file'] = 'logstash.conf'
default['logstash']['agent']['config_templates'] = []
default['logstash']['agent']['config_templates_cookbook'] = 'logstash'
default['logstash']['agent']['config_templates_variables'] = {}
default['logstash']['agent']['base_config'] = 'agent.conf.erb'
default['logstash']['agent']['base_config_cookbook'] = 'logstash'
default['logstash']['agent']['xms'] = '384M'
default['logstash']['agent']['xmx'] = '384M'
default['logstash']['agent']['java_opts'] = ''
default['logstash']['agent']['gc_opts'] = '-XX:+UseParallelOldGC'
default['logstash']['agent']['ipv4_only'] = false
default['logstash']['agent']['debug'] = false
# allow control over the upstart config
default['logstash']['agent']['upstart_with_sudo'] = false
default['logstash']['agent']['upstart_respawn_count'] = 5
default['logstash']['agent']['upstart_respawn_timeout'] = 30
default['logstash']['agent']['init_method'] = 'native' # native or runit
default['logstash']['agent']['init_method'] = 'native'
default['logstash']['agent']['workers'] = 1

# allow control over the upstart config
default['logstash']['server']['upstart_with_sudo'] = false

# logrotate options for logstash agent
default['logstash']['agent']['logrotate']['options'] = %w{ missingok notifempty }
# stop/start on logrotate?
default['logstash']['agent']['logrotate']['stopstartprepost'] = false

# roles/flasgs for various autoconfig/discovery components
default['logstash']['agent']['server_role'] = 'logstash_server'

# for use in case recipe used w/ chef-solo, default to self
default['logstash']['agent']['server_ipaddress'] = ''

default['logstash']['agent']['inputs'] = []
default['logstash']['agent']['filters'] = []
default['logstash']['agent']['outputs'] = []
