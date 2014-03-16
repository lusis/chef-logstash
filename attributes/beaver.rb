# Encoding: utf-8
default['logstash']['beaver']['log_file'] = '/var/log/logstash/beaver.log'
default['logstash']['beaver']['pip_package'] = 'beaver==22'
default['logstash']['beaver']['pika']['pip_package'] = 'pika==0.9.8'
default['logstash']['beaver']['zmq']['pip_package'] = 'pyzmq==2.1.11'
default['logstash']['beaver']['server_role'] = 'logstash_server'
default['logstash']['beaver']['server_ipaddress'] = nil
default['logstash']['beaver']['inputs'] = []
default['logstash']['beaver']['outputs'] = []
default['logstash']['beaver']['format'] = 'json'

default['logstash']['beaver']['logrotate']['options'] = %w(missingok notifempty compress copytruncate)
default['logstash']['beaver']['logrotate']['postrotate'] = 'invoke-rc.d logstash_beaver force-reload >/dev/null 2>&1 || true'
