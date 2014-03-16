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

logstash_instance node['logstash']['server']['name'] do
  base_directory    node['logstash']['server']['basedir']
  version           node['logstash']['server']['version']
  checksum          node['logstash']['server']['checksum']
  source_url        node['logstash']['server']['source_url']
  install_type      node['logstash']['server']['install_type']
  user              node['logstash']['server']['user']
  group             node['logstash']['server']['group']
end

logstash_home = "#{node['logstash']['server']['basedir']}/#{node['logstash']['server']['name']}"

# fix search if chef solo
if Chef::Config[:solo]
  es_server_ip = node['logstash']['elasticsearch_ip']
  graphite_server_ip = node['logstash']['graphite_ip']
else
  es_results = search(:node, node['logstash']['elasticsearch_query'])
  graphite_results = search(:node, node['logstash']['graphite_query'])

  if !es_results.empty?
    es_server_ip = es_results[0]['ipaddress']
  else
    es_server_ip = node['logstash']['elasticsearch_ip']
  end

  if !graphite_results.empty?
    graphite_server_ip = graphite_results[0]['ipaddress']
  else
    graphite_server_ip = node['logstash']['graphite_ip']
  end
end

# services are hard!
include_recipe 'pleaserun::default'
service_resource = "service[logstash_#{node['logstash']['server']['name']}]"

logstash_args = ['agent', '-f', "#{node['logstash']['server']['home']}/etc/conf.d/"]
logstash_args.concat ['--pluginpath', node['logstash']['server']['pluginpath']] if node['logstash']['server']['pluginpath']
logstash_args.concat ['-vv'] if node['logstash']['server']['debug']
logstash_args.concat ['-l', "#{logstash_home}/log/#{node['logstash']['server']['log_file']}"] if node['logstash']['server']['log_file']
logstash_args.concat ['-w', node['logstash']['server']['workers'].to_s ] if node['logstash']['server']['workers']

pleaserun "logstash_#{node['logstash']['server']['name']}" do
  name        "logstash_#{node['logstash']['server']['name']}"
  program     "#{logstash_home}/bin/logstash"
  args        logstash_args
  description "logstash_#{node['logstash']['server']['name']}"
  chdir       logstash_home
  user        node['logstash']['server']['user']
  group       node['logstash']['server']['group']
  action      :create
end

# add in any custom patterns
node['logstash']['server']['patterns_templates'].each do |name, template|
  template "#{node['logstash']['server']['home']}/patterns/#{File.basename(template)}" do
    source "#{template}.erb"
    cookbook node['logstash']['server']['patterns_templates_cookbook']
    owner node['logstash']['server']['user']
    group node['logstash']['server']['group']
    mode '0644'
    notifies :restart, service_resource
    not_if { node['logstash']['server']['patterns_templates'].empty? }
  end
end

node['logstash']['server']['config_templates'].each do |name, template|
  template "#{node['logstash']['server']['home']}/etc/conf.d/#{File.basename(template)}" do
    source "#{template}.erb"
    cookbook node['logstash']['server']['config_templates_cookbook']
    owner node['logstash']['server']['user']
    group node['logstash']['server']['group']
    mode '0644'
    # variables node['logstash']['server']['config_templates_variables'][config_template]
    notifies :restart, service_resource
    action :create
    not_if { node['logstash']['server']['config_templates'].empty? }
  end
end

service "logstash_#{node['logstash']['server']['name']}" do
  supports restart: true, reload: true, start: true, enable: true
  action  [:enable, :start]
end

# set up logrotate
include_recipe 'logrotate'
logrotate_app "logstash_#{node['logstash']['server']['name']}" do
  path "#{log_dir}/*.log"
  size node['logstash']['server']['logging']['maxSize'] if node['logstash']['server']['logging']['useFileSize']
  frequency node['logstash']['server']['logging']['rotateFrequency']
  rotate node['logstash']['server']['logging']['maxBackup']
  options node['logstash']['server']['logrotate']['options']
  create "664 #{node['logstash']['server']['user']} #{node['logstash']['server']['group']}"
end
