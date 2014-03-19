default['logstash']['server']['version'] = '1.3.3'
default['logstash']['server']['home'] = "#{node['logstash']['basedir']}/server"
default['logstash']['server']['log_file'] = '/mnt/log/logstash/server.log'
default['logstash']['server']['source_url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.3.3-flatjar.jar'
default['logstash']['server']['checksum'] = 'a83503bd2aa32e1554b98f812d0b411fbc5f7b6b21cebb48b7d344474f2dfc6d'
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

default['logstash']['server']['init_method'] = 'native' # native or runit
# roles/flags for various autoconfig/discovery components
default['logstash']['server']['enable_embedded_es'] = true

default['logstash']['server']['inputs'] = []
default['logstash']['server']['filters'] = []
default['logstash']['server']['outputs'] = []

default['logstash']['server']['logrotate']['options'] = [ 'missingok', 'notifempty', 'compress', 'copytruncate' ]
  
