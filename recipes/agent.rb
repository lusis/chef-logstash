# Encoding: utf-8
#
# Cookbook Name:: logstash
# Recipe:: agent
#
#

name = 'agent'

Chef::Application.fatal!("attribute hash node['logstash']['instance']['#{name}'] must exist.") if node['logstash']['instance'][name].nil?

# these should all default correctly.  listing out for example.
logstash_instance name do
  action            :create
end

# services are hard! Let's go LWRP'ing.   FIREBALL! FIREBALL! FIREBALL!
logstash_service name do
  action      [:enable, :start]
end

logstash_config name do
  variables(
    input_file_name: '/var/log/syslog',
    input_file_type: 'syslog'
  )
  action [:create]
end

logstash_pattern name do
  action [:create]
end
