default['logstash']['server']['version'] = '1.2.2'
default['logstash']['server']['home'] = "#{node['logstash']['basedir']}/server"
default['logstash']['server']['log_file'] = '/var/log/logstash/server.log'
default['logstash']['server']['source_url'] = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.2.2-flatjar.jar'
default['logstash']['server']['checksum'] = '6b0974eed6814f479b68259b690e8c27ecbca2817b708c8ef2a11ce082b1183c'
default['logstash']['server']['install_method'] = 'jar' # Either `source` or `jar`
default['logstash']['server']['init_method'] = 'native' # native or runit
default['logstash']['server']['init_notify'] =
  if node['logstash']['server']['init_method'] == 'runit'
    'runit_service[logstash_server]'
  else
    'service[logstash_server]'
  end

# Directories
default['logstash']['server']['dir_defaults'] = {
  action:    :create,
  mode:      '0755',
  owner:     node['logstash']['user'],
  group:     node['logstash']['group'],
  recursive: true
}

default['logstash']['server']['dirs'] = {
  config: {
    path: File.join(node['logstash']['server']['home'], 'etc')
  },
  patterns: {
    path: File.join(node['logstash']['server']['home'], 'etc', 'patterns')
  },
  logs: {
    path: File.dirname(node['logstash']['server']['log_file'])
  }
}

# Templates
default['logstash']['server']['template_defaults'] = {
  notifies: ['restart', node['logstash']['server']['init_notify']],
  action:   'create',
  cookbook: 'logstash',
  owner:    node['logstash']['user'],
  group:    node['logstash']['group'],
  mode:     '0755'
}

default['logstash']['server']['templates'] = {}

default['logstash']['server']['cli']['config_path'] = node['logstash']['server']['dirs']['config']['path']
default['logstash']['server']['xms'] = '1024M'
default['logstash']['server']['xmx'] = '1024M'
default['logstash']['server']['java_opts'] = ''
default['logstash']['server']['gc_opts'] = '-XX:+UseParallelOldGC'
default['logstash']['server']['ipv4_only'] = false
default['logstash']['server']['debug'] = false
default['logstash']['server']['workers'] = 1

# allow control over the upstart config
default['logstash']['server']['upstart_with_sudo'] = false

# roles/flags for various autoconfig/discovery components
default['logstash']['server']['enable_embedded_es'] = true

default['logstash']['server']['inputs'] = []
default['logstash']['server']['filters'] = []
default['logstash']['server']['outputs'] = []

default['logstash']['server']['web']['enable']  = false
default['logstash']['server']['web']['address'] = '0.0.0.0'
default['logstash']['server']['web']['port']    = '9292'

default['logstash']['server']['logrotate']['options'] = [ 'missingok', 'notifempty', 'compress', 'copytruncate' ]
