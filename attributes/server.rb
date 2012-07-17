
default['logstash']['server']['version'] = "1.1.1"
default['logstash']['server']['source_url'] = 'http://semicomplete.com/files/logstash/logstash-1.1.1-monolithic.jar'
default['logstash']['server']['checksum'] = '36f462b50efad0773b3ff94920d1de500faa236cb0d81439110b50b08978444d'
default['logstash']['server']['install_method'] = "jar" # Either `source` or `jar`
default['logstash']['server']['base_config'] = "server.conf.erb"
default['logstash']['server']['base_config_cookbook'] = "logstash"
default['logstash']['server']['xms'] = "1024M"
default['logstash']['server']['xmx'] = "1024M"
default['logstash']['server']['debug'] = false
default['logstash']['server']['home'] = '/opt/logstash/server'

# roles/flags for various autoconfig/discovery components
default['logstash']['server']['enable_embedded_es'] = true
default['logstash']['server']['inputs'] = []
default['logstash']['server']['filters'] = []
default['logstash']['server']['outputs'] = []
