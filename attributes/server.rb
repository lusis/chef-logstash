default['logstash']['server']['version'] = '1.1.1'
default['logstash']['server']['source_url'] = 'http://databits.net/petef/tmp/logstash-1.1.1-pre-monolithic-jruby1.7.0pre1.jar'
default['logstash']['server']['checksum'] = '6ca41718706c118ee6abb339bec9225b5d56cc3dc258d5053e64d00e24cdb918'
default['logstash']['server']['install_method'] = 'jar' # Either `source` or `jar`
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
