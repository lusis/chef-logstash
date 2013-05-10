default['logstash']['agent']['version'] = '1.1.9'
default['logstash']['agent']['source_url'] = 'https://logstash.objects.dreamhost.com/release/logstash-1.1.9-monolithic.jar'
default['logstash']['agent']['checksum'] = 'e444e89a90583a75c2d6539e5222e2803621baa0ae94cb77dbbcebacdc0c3fc7'
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
default['logstash']['agent']['use_runit'] = false
default['logstash']['agent']['log_dir'] = '/var/log/logstash_agent'

# roles/flasgs for various autoconfig/discovery components
default['logstash']['agent']['server_role'] = 'logstash_server'

# for use in case recipe used w/ chef-solo, default to self
default['logstash']['agent']['server_ipaddress'] = ''

# When using runit, we can provide alternative templates for the log
# and run scripts
default['logstash']['agent']['runit_cookbook'] = 'logstash'
default['logstash']['agent']['runit_run_template'] = 'logstash_agent'
default['logstash']['agent']['runit_log_template'] = 'logstash_agent'


default['logstash']['agent']['inputs'] = []
default['logstash']['agent']['filters'] = []
default['logstash']['agent']['outputs'] = []
