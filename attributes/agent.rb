default['logstash']['agent']['version'] = "1.1.1"
default['logstash']['agent']['source_url'] = 'http://databits.net/petef/tmp/logstash-1.1.1-pre-monolithic-jruby1.7.0pre1.jar'
default['logstash']['agent']['checksum'] = '6ca41718706c118ee6abb339bec9225b5d56cc3dc258d5053e64d00e24cdb918'
default['logstash']['agent']['install_method'] = "jar" # Either `source` or `jar`
default['logstash']['agent']['base_config'] = "agent.conf.erb"
default['logstash']['agent']['base_config_cookbook'] = "logstash"
default['logstash']['agent']['xms'] = "384M"
default['logstash']['agent']['xmx'] = "384M"
default['logstash']['agent']['debug'] = false

# roles/flasgs for various autoconfig/discovery components
default['logstash']['agent']['server_role'] = "logstash_server"

# for use in case recipe used w/ chef-solo, default to self
default['logstash']['agent']['server_ipaddress'] = ""
default['logstash']['agent']['inputs'] = []
default['logstash']['agent']['filters'] = []
default['logstash']['agent']['outputs'] = []


