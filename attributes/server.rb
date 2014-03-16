# Encoding: utf-8
default['logstash']['server'] = node['logstash']['default']

override['logstash']['server']['config_templates']    = { 'syslog' => 'config/syslog.conf', 'stdout' => 'config/stdout.conf' }
override['logstash']['default']['patterns_templates'] = { 'default' => 'patterns/patterns' }
# override any defaults here.
