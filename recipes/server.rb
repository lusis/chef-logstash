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
attributes = node['logstash']['instance'][name]

# these should all default correctly.  listing out for example.
logstash_instance name do
  base_directory    attributes['basedir']
  version           attributes['version']
  checksum          attributes['checksum']
  source_url        attributes['source_url']
  install_type      attributes['install_type']
  user              attributes['user']
  group             attributes['group']
  enable_logrotate  attributes['enable_logrotate']
  action            :create
end

# fix search if chef solo
if Chef::Config[:solo]
  es_server_ip = attributes['elasticsearch_ip']
  graphite_server_ip = attributes['graphite_ip']
else
  es_results = search(:node, attributes['elasticsearch_query'])
  graphite_results = search(:node, attributes['graphite_query'])

  if !es_results.empty?
    es_server_ip = es_results[0]['ipaddress']
  else
    es_server_ip = attributes['elasticsearch_ip']
  end

  if !graphite_results.empty?
    graphite_server_ip = graphite_results[0]['ipaddress']
  else
    graphite_server_ip = attributes['graphite_ip']
  end
end

# services are hard! Let's go LWRP'ing.   FIREBALL! FIREBALL! FIREBALL!
logstash_service name do
  action      [:enable, :start]
end

logstash_config name do
  action [:create]
  not_if { attributes['config_templates'].empty? }
end

# add in any custom patterns
attributes['patterns_templates'].each do |template, file|
  template "#{attributes['basedir']}/#{name}/patterns/#{File.basename(file)}" do
    source "#{file}.erb"
    cookbook attributes['patterns_templates_cookbook']
    owner attributes['user']
    group attributes['group']
    mode '0644'
    # notifies :restart, service_resource
    not_if { attributes['patterns_templates'].empty? }
  end
end
