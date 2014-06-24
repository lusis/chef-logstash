# Encoding: utf-8
#
# Author:: John E. Vincent
# Author:: Bryan W. Berry (<bryan.berry@gmail.com>)
# Copyright 2012, John E. Vincent
# Copyright 2012, Bryan W. Berry
# License: Apache 2.0
# Cookbook Name:: logstash
# Recipe:: server
#
#

# install logstash 'server'

name = 'server'

Chef::Application.fatal!("attribute hash node['logstash']['instance']['#{name}'] must exist.") if node['logstash']['instance'][name].nil?

# these should all default correctly.  listing out for example.
logstash_instance name do
  action            :create
end

# services are hard! Let's go LWRP'ing.   FIREBALL! FIREBALL! FIREBALL!
logstash_service name do
  action      [:enable]
end

embedded_es = node['logstash']['instance'][name]['enable_embedded_es'] || node['logstash']['instance']['default']['enable_embedded_es']
es_cluster = node['logstash']['instance'][name]['elasticsearch_cluster'] || node['logstash']['instance']['default']['elasticsearch_cluster']
es_index = node['logstash']['instance'][name]['es_index'] || node['logstash']['instance']['default']['es_index']

bind_host_if = node['logstash']['instance'][name]['bind_host_interface'] || node['logstash']['instance']['default']['bind_host_interface']
if !bind_host_if.empty?
  bind_host = ::Logstash.get_ip_for_node(node, bind_host_if)
else
  bind_host = nil
end

my_templates  = {
  'input_syslog' => 'config/input_syslog.conf.erb',
  'output_stdout' => 'config/output_stdout.conf.erb',
  'output_elasticsearch' => 'config/output_elasticsearch.conf.erb'
}

logstash_config name do
  templates my_templates
  action [:create]
  variables(
    elasticsearch_ip: ::Logstash.service_ip(node, name, 'elasticsearch'),
    bind_host: bind_host,
    elasticsearch_cluster: es_cluster,
    elasticsearch_embedded: embedded_es,
    es_index: es_index
  )
end
# ^ see `.kitchen.yml` for example attributes to configure templates.

logstash_plugins 'contrib' do
  instance name
  action [:create]
end

logstash_pattern name do
  action [:create]
end

logstash_service name do
  action      [:start]
end

logstash_curator 'server' do
  action [:create]
end
