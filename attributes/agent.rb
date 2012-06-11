default[:logstash][:agent][:version] = "1.1.0.1"
default[:logstash][:agent][:source_url] = "http://semicomplete.com/files/logstash/logstash-#{node[:logstash][:agent][:version]}-monolithic.jar"
default[:logstash][:agent][:checksum] = "9808bd88725f3166c26d21b96226da3e36dad089cea91f6e22a645365724e4d9"
default[:logstash][:agent][:install_method] = "source" # Either `source` or `jar`
default[:logstash][:agent][:base_config] = "agent.conf.erb"
default[:logstash][:agent][:xms] = "384M"
default[:logstash][:agent][:xmx] = "384M"
default[:logstash][:agent][:debug] = false

# roles/flasgs for various autoconfig/discovery components
default[:logstash][:agent][:server_role] = "logstash_server"
