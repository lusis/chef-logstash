default['logstash']['agent']['version'] = "1.1.1"
default['logstash']['agent']['source_url'] = 'http://semicomplete.com/files/logstash/logstash-1.1.1-monolithic.jar'
default['logstash']['agent']['checksum'] =  '36f462b50efad0773b3ff94920d1de500faa236cb0d81439110b50b08978444d'
default['logstash']['agent']['install_method'] = "jar" # Either `source` or `jar`
default['logstash']['agent']['base_config'] = "agent.conf.erb"
default['logstash']['agent']['base_config_cookbook'] = "logstash"
default['logstash']['agent']['xms'] = "384M"
default['logstash']['agent']['xmx'] = "384M"
default['logstash']['agent']['java_opts'] = ""
default['logstash']['agent']['gc_opts'] = "-XX:+UseParallelOldGC"
default['logstash']['agent']['ipv4_only'] = false
default['logstash']['agent']['debug'] = false

# roles/flasgs for various autoconfig/discovery components
default['logstash']['agent']['server_role'] = "logstash_server"

# for use in case recipe used w/ chef-solo, default to self
default['logstash']['agent']['server_ipaddress'] = ""
default['logstash']['agent']['inputs'] = []
default['logstash']['agent']['filters'] = []
default['logstash']['agent']['outputs'] = []


