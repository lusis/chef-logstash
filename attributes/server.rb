# Encoding: utf-8

# slurp in defaults to named instance
default['logstash']['instance']['server'] = node['logstash']['instance']['default']

# override any defaults here.

set['logstash']['instance']['server']['config_templates']   = {
  'input_syslog' => 'config/input_syslog.conf.erb',
  'output_stdout' => 'config/output_stdout.conf.erb',
  'output_elasticsearch' => 'config/output_elasticsearch.conf.erb'
}
set['logstash']['instance']['server']['pattern_templates']  = { 'default' => 'patterns/custom_patterns.erb' }
set['logstash']['instance']['server']['elasticsearch_ip']  = '127.0.0.1'
set['logstash']['instance']['server']['enable_embedded_es'] = true
