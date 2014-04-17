#Default values for apt repos
default['logstash']['repo']['apt']['url'] = "http://packages.elasticsearch.org/logstash/1.3/debian"
default['logstash']['repo']['apt']['gpgkey'] = "http://packages.elasticsearch.org/GPG-KEY-elasticsearch"
default['logstash']['repo']['apt']['distro'] = "stable"
default['logstash']['repo']['apt']['components'] = ["main"]
#Default values for yum repos
default['logstash']['repo']['yum']['url'] = "http://packages.elasticsearch.org/logstash/1.3/centos"
default['logstash']['repo']['yum']['gpgkey'] = "http://packages.elasticsearch.org/GPG-KEY-elasticsearch"
default['logstash']['repo']['yum']['description'] = "logstash repository"

