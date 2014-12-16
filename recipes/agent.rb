# Encoding: utf-8
#
# Cookbook Name:: logstash
# Recipe:: agent
#
#

name = 'agent'

# these should all default correctly.  listing out for example.
logstash_instance name do
  action            :create
end

# services are hard! Let's go LWRP'ing.   FIREBALL! FIREBALL! FIREBALL!
logstash_service name do
  action      [:enable]
end

logstash_config name do
  variables(
    input_file_name: '/var/log/syslog',
    input_file_type: 'syslog'
  )
  notifies :restart, "logstash_service[#{name}]"
  action [:create]
end

logstash_pattern name do
  action [:create]
end
