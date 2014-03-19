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
  enable_logrotate  node['logstash']['instance'][name]['enable_logrotate']
  action            :create
end

# services are hard! Let's go LWRP'ing.   FIREBALL! FIREBALL! FIREBALL!
logstash_service name do
  action      [:enable, :start]
end

# add in any custom patterns
node['logstash']['instance'][name]['patterns_templates'].each do |template, file|
  template "#{node['logstash']['instance'][name]['home']}/patterns/#{File.basename(file)}" do
    source "#{file}.erb"
    cookbook node['logstash']['instance'][name]['patterns_templates_cookbook']
    owner node['logstash']['instance'][name]['user']
    group node['logstash']['instance'][name]['group']
    mode '0644'
    # notifies :restart, service_resource
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
    # notifies :restart, service_resource
    action :create
    not_if { node['logstash']['instance'][name]['config_templates'].empty? }
  end
end
