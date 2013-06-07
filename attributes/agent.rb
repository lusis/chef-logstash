default['logstash']['agent']['version'] = '1.1.13'
default['logstash']['agent']['source_url'] = 'https://logstash.objects.dreamhost.com/release/logstash-1.1.13-flatjar.jar'
default['logstash']['agent']['checksum'] = '5ba0639ff4da064c2a4f6a04bd7006b1997a6573859d3691e210b6855e1e47f1'
default['logstash']['agent']['install_method'] = 'jar' # Either `source` or `jar`
default['logstash']['agent']['patterns_dir'] = 'agent/etc/patterns'
default['logstash']['agent']['base_config'] = 'agent.conf.erb'
default['logstash']['agent']['base_config_cookbook'] = 'logstash'
default['logstash']['agent']['xms'] = '384M'
default['logstash']['agent']['xmx'] = '384M'
default['logstash']['agent']['java_opts'] = ''
default['logstash']['agent']['gc_opts'] = '-XX:+UseParallelOldGC'
default['logstash']['agent']['ipv4_only'] = false
default['logstash']['agent']['debug'] = false
default['logstash']['agent']['upstart_with_sudo'] = false

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
