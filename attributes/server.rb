# Encoding: utf-8
default['logstash']['instance']['server'] = node['logstash']['instance']['default']

override['logstash']['instance']['server']['config_templates']   = { 'syslog' => 'config/syslog.conf', 'stdout' => 'config/stdout.conf' }
override['logstash']['instance']['server']['patterns_templates'] = { 'default' => 'patterns/patterns' }
# override any defaults here.
