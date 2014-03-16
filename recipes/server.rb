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
node.override['logstash']['instance'][name]['name'] = name
node.save unless Chef::Config[:solo]

# these should all default correctly.  listing out for example.
logstash_instance name do
  base_directory    node['logstash']['instance'][name]['basedir']
  version           node['logstash']['instance'][name]['version']
  checksum          node['logstash']['instance'][name]['checksum']
  source_url        node['logstash']['instance'][name]['source_url']
  install_type      node['logstash']['instance'][name]['install_type']
  user              node['logstash']['instance'][name]['user']
  group             node['logstash']['instance'][name]['group']
  action            :create # :delete to remove
end

logstash_home = "#{node['logstash']['instance'][name]['basedir']}/#{name}"

# fix search if chef solo
if Chef::Config[:solo]
  es_server_ip = node['logstash']['instance'][name]['elasticsearch_ip']
  graphite_server_ip = node['logstash']['instance'][name]['graphite_ip']
else
  es_results = search(:node, node['logstash']['instance'][name]['elasticsearch_query'])
  graphite_results = search(:node, node['logstash']['instance'][name]['graphite_query'])

  if !es_results.empty?
    es_server_ip = es_results[0]['ipaddress']
  else
    es_server_ip = node['logstash']['instance'][name]['elasticsearch_ip']
  end

  if !graphite_results.empty?
    graphite_server_ip = graphite_results[0]['ipaddress']
  else
    graphite_server_ip = node['logstash']['instance'][name]['graphite_ip']
  end
end

# services are hard!
service_resource = "service[logstash_#{name}]"

logstash_service name do
  action      :create
end

# add in any custom patterns
node['logstash']['instance'][name]['patterns_templates'].each do |template, file|
  template "#{node['logstash']['instance'][name]['home']}/patterns/#{File.basename(file)}" do
    source "#{file}.erb"
    cookbook node['logstash']['instance'][name]['patterns_templates_cookbook']
    owner node['logstash']['instance'][name]['user']
    group node['logstash']['instance'][name]['group']
    mode '0644'
    notifies :restart, service_resource
    not_if { node['logstash']['instance'][name]['patterns_templates'].empty? }
  end
end

node['logstash']['instance'][name]['config_templates'].each do |template, file|
  template "#{node['logstash']['instance'][name]['home']}/etc/conf.d/#{File.basename(file)}" do
    source "#{file}.erb"
    cookbook node['logstash']['instance'][name]['config_templates_cookbook']
    owner node['logstash']['instance'][name]['user']
    group node['logstash']['instance'][name]['group']
    mode '0644'
    # variables node['logstash']['instance'][name]['config_templates_variables'][config_template]
    notifies :restart, service_resource
    action :create
    not_if { node['logstash']['instance'][name]['config_templates'].empty? }
  end
end

service "logstash_#{name}" do
  supports restart: true, reload: true, start: true, enable: true
  action  [:enable]
end

# set up logrotate
include_recipe 'logrotate'
logrotate_app "logstash_#{name}" do
  path "#{log_dir}/*.log"
  size node['logstash']['instance'][name]['logging']['maxSize'] if node['logstash']['instance'][name]['logging']['useFileSize']
  frequency node['logstash']['instance'][name]['logging']['rotateFrequency']
  rotate node['logstash']['instance'][name]['logging']['maxBackup']
  options node['logstash']['instance'][name]['logrotate']['options']
  create "664 #{node['logstash']['instance'][name]['user']} #{node['logstash']['instance'][name]['group']}"
end
