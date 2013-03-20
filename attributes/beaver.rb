
default['logstash']['beaver']['pip_package'] = "beaver==22"
default['logstash']['beaver']['zmq']['pip_package'] = "pyzmq==2.1.11"
default['logstash']['beaver']['server_role'] = "logstash_server"
default['logstash']['beaver']['server_ipaddress'] = nil
default['logstash']['beaver']['inputs'] = []
default['logstash']['beaver']['outputs'] = []

default['logstash']['beaver']['init_style'] = nil # Same than node['logstash']['init_style']

default['logstash']['beaver']['user'] = nil # Same than node['logstash']['user']
default['logstash']['beaver']['group'] = nil # Same than node['logstash']['group']
