default['logstash']['server']['version'] = '1.1.9'
default['logstash']['server']['source_url'] = 'https://logstash.objects.dreamhost.com/release/logstash-1.1.9-monolithic.jar'
default['logstash']['server']['checksum'] = 'e444e89a90583a75c2d6539e5222e2803621baa0ae94cb77dbbcebacdc0c3fc7'
default['logstash']['server']['install_method'] = 'jar' # Either `source` or `jar`
default['logstash']['server']['patterns_dir'] = 'server/etc/patterns'
default['logstash']['server']['base_config'] = 'server.conf.erb'
default['logstash']['server']['base_config_cookbook'] = 'logstash'
default['logstash']['server']['xms'] = '1024M'
default['logstash']['server']['xmx'] = '1024M'
default['logstash']['server']['java_opts'] = ''
default['logstash']['server']['gc_opts'] = '-XX:+UseParallelOldGC'
default['logstash']['server']['ipv4_only'] = false
default['logstash']['server']['debug'] = false
default['logstash']['server']['home'] = '/opt/logstash/server'
default['logstash']['server']['install_rabbitmq'] = true

# roles/flags for various autoconfig/discovery components
default['logstash']['server']['enable_embedded_es'] = true

default['logstash']['server']['inputs'] = []
default['logstash']['server']['filters'] = []
default['logstash']['server']['outputs'] = []
