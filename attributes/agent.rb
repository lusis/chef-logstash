# Encoding: utf-8

# slurp in defaults to named instance
default['logstash']['instance']['agent'] = node['logstash']['instance']['default']

# override any defaults here.

override['logstash']['instance']['agent']['config_templates']   = {
  'input_file' => 'config/input_file.conf.erb',
  'output_stdout' => 'config/output_stdout.conf.erb'
}

override['logstash']['instance']['default']['config_templates_variables'] = {
  input_file_name: '/var/log/syslog',
  input_file_type: 'syslog'
}

override['logstash']['instance']['agent']['enable_embedded_es'] = false
override['logstash']['instance']['agent']['supervisor_gid'] = 'adm'
