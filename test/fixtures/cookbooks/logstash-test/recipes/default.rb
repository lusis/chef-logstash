include_recipe 'chef-sugar'

# configure ES instance, small memory footprint, enable and start it
include_recipe 'elasticsearch'
es_conf = resources("elasticsearch_configure[elasticsearch]")
es_conf.allocated_memory '128m'
es_svc = resources("elasticsearch_service[elasticsearch]")
es_svc.service_actions [:enable, :start]

# install logstash without embedded ES
include_recipe 'logstash::server'

# send logs to logstash now
include_recipe 'rsyslog::client'
