default['logstash']['agent']['version'] = '1.2.2'
default['logstash']['agent']['log_file'] = '/var/log/logstash/agent.log'
default['logstash']['agent']['source_url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.2.2-flatjar.jar'
default['logstash']['agent']['checksum'] = '6b0974eed6814f479b68259b690e8c27ecbca2817b708c8ef2a11ce082b1183c'
default['logstash']['agent']['install_method'] = 'jar' # Either `source` or `jar`
default['logstash']['agent']['home'] = "#{node['logstash']['basedir']}/agent"
default['logstash']['agent']['patterns_dir'] = 'etc/patterns'
default['logstash']['agent']['config_dir'] = 'etc/conf.d'
default['logstash']['agent']['config_file'] = 'logstash.conf'
default['logstash']['agent']['config_templates'] = []
default['logstash']['agent']['config_templates_cookbook'] = 'logstash'
default['logstash']['agent']['config_templates_variables'] = { }
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

# number of logstash filter workers, set to number of CPU cores to speed up processing
default['logstash']['agent']['workers'] = 0

# logrotate options for logstash agent
default['logstash']['agent']['logrotate']['options'] = [ "missingok", "notifempty" ]
# stop/start on logrotate?
default['logstash']['agent']['logrotate']['stopstartprepost'] = false

# roles/flasgs for various autoconfig/discovery components
default['logstash']['agent']['server_role'] = 'logstash_server'

# for use in case recipe used w/ chef-solo, default to self
default['logstash']['agent']['server_ipaddress'] = ''

default['logstash']['agent']['inputs'] = []
default['logstash']['agent']['filters'] = []
default['logstash']['agent']['outputs'] = []
