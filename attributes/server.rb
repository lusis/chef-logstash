default['logstash']['server']['version'] = '1.2.2'
default['logstash']['server']['home'] = "#{node['logstash']['basedir']}/server"
default['logstash']['server']['log_file'] = '/var/log/logstash/server.log'
default['logstash']['server']['source_url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.2.2-flatjar.jar'
default['logstash']['server']['checksum'] = '6b0974eed6814f479b68259b690e8c27ecbca2817b708c8ef2a11ce082b1183c'
default['logstash']['server']['install_method'] = 'jar' # Either `source` or `jar`
default['logstash']['server']['patterns_dir'] = 'etc/patterns'
default['logstash']['server']['config_dir'] = 'etc/conf.d'
default['logstash']['server']['config_file'] = 'logstash.conf'
default['logstash']['server']['config_templates'] = []
default['logstash']['server']['config_templates_cookbook'] = 'logstash'
default['logstash']['server']['config_templates_variables'] = { }
default['logstash']['server']['base_config'] = 'server.conf.erb' # set blank if don't want data driven config
default['logstash']['server']['base_config_cookbook'] = 'logstash'
default['logstash']['server']['xms'] = '1024M'
default['logstash']['server']['xmx'] = '1024M'
default['logstash']['server']['java_opts'] = ''
default['logstash']['server']['gc_opts'] = '-XX:+UseParallelOldGC'
default['logstash']['server']['ipv4_only'] = false
default['logstash']['server']['debug'] = false

default['logstash']['server']['install_rabbitmq'] = false

default['logstash']['server']['init_method'] = 'native' # native or runit
# roles/flags for various autoconfig/discovery components
default['logstash']['server']['enable_embedded_es'] = true

default['logstash']['server']['inputs'] = []
default['logstash']['server']['filters'] = []
default['logstash']['server']['outputs'] = []



default['logstash']['server']['logrotate']['options'] = [ 'missingok', 'notifempty', 'compress', 'copytruncate' ]
