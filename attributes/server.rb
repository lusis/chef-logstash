default[:logstash][:server][:version] = "1.1.0.1"
default[:logstash][:server][:source_url] = "http://semicomplete.com/files/logstash/logstash-#{node[:logstash][:server][:version]}-monolithic.jar"
default[:logstash][:server][:checksum] = "9808bd88725f3166c26d21b96226da3e36dad089cea91f6e22a645365724e4d9"
default[:logstash][:server][:install_method] = "source" # Either `source` or `jar`
default[:logstash][:server][:base_config] = "server.conf.erb"
default[:logstash][:server][:xms] = "1024M"
default[:logstash][:server][:xmx] = "1024M"
default[:logstash][:server][:debug] = false

# roles/flags for various autoconfig/discovery components
default[:logstash][:server][:enable_embedded_es] = true
