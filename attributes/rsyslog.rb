default['logstash']['rsyslog']['packages'] = %w(rsyslog)
default['logstash']['rsyslog']['write_config'] = true
default['logstash']['rsyslog']['config_file'] = '/etc/rsyslog.conf'
default['logstash']['rsyslog']['config_dir'] = '/etc/rsyslog.d'
default['logstash']['rsyslog']['base_config'] = 'rsyslog.conf.erb'
default['logstash']['rsyslog']['base_config_cookbook'] = 'logstash'
default['logstash']['rsyslog']['base_config_section'] = 'rsyslog-section.conf.erb'
default['logstash']['rsyslog']['base_config_section_cookbook'] = 'logstash'
default['logstash']['rsyslog']['ship_everything'] = true
default['logstash']['rsyslog']['tcp_server'] = nil # e.g. "logstash-server-01.example.com:514"

default['logstash']['rsyslog']['repeated_msg_reduction'] = 'on'
default['logstash']['rsyslog']['file_owner'] = 'syslog'
default['logstash']['rsyslog']['file_group'] = 'adm'
default['logstash']['rsyslog']['priv_drop_to_user'] = 'syslog'
default['logstash']['rsyslog']['priv_drop_to_group'] = 'syslog'
default['logstash']['rsyslog']['mark_message_period'] = 600
default['logstash']['rsyslog']['work_directory'] = '/var/spool/rsyslog'

default['logstash']['rsyslog']['config_sections'] = []
