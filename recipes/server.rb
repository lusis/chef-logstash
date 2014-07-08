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

my_templates  = node['logstash']['instance']['default']['config_templates']

if my_templates.empty?
  my_templates = {
    'input_syslog' => 'config/input_syslog.conf.erb',
    'output_stdout' => 'config/output_stdout.conf.erb',
    'output_elasticsearch' => 'config/output_elasticsearch.conf.erb'
  }
end

logstash_config name do
  templates my_templates
  action [:create]
  variables(
    elasticsearch_embedded: true
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
