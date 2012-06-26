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

include_recipe "logstash::default"
include_recipe "logrotate"


if Chef::Config[:solo] 
  es_server_ip = node['logstash']['elasticsearch_ip']
  graphite_server_ip = node['logstash']['graphite_ip']
else
  es_results = search(:node, "role:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}")
  graphite_results = search(:node, "role:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}")

  unless es_results.empty?
    es_server_ip = es_results[0]['ipaddress']
  end
  unless es_results.empty?
    graphite_server_ip = es_results[0]['ipaddress']
  end
end

#create directory for logstash
directory "#{node['logstash']['home']}/server" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

%w{bin etc lib log tmp patterns  }.each do |ldir|
  
  directory "#{node['logstash']['basedir']}/server/#{ldir}" do
    action :create
    mode "0755"
    owner node['logstash']['user']
    group node['logstash']['group']
  end

  link "/var/lib/logstash/#{ldir}" do
    to "#{node['logstash']['basedir']}/server/#{ldir}"
  end
end
  
#installation
if node['logstash']['server']['install_method'] == "jar"
  remote_file "#{node['logstash']['basedir']}/server/lib/logstash-#{node['logstash']['server']['version']}.jar" do
    owner "root"
    group "root"
    mode "0755"
    source node['logstash']['server']['source_url']
    checksum node['logstash']['server']['checksum']
  not_if {File.exists?("#{node['logstash']['basedir']}/server/lib/logstash-#{node['logstash']['server']['version']}.jar")}
  end
  link "#{node['logstash']['basedir']}/server/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/server/lib/logstash-#{node['logstash']['server']['version']}.jar"
    notifies :restart, "service[logstash_server]"
  end
else
  include_recipe "logstash::source"

  link "#{node['logstash']['basedir']}/server/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{node['logstash']['source']['sha']}-monolithic.jar"
    notifies :restart, "service[logstash_server]"
  end
end

directory "#{node['logstash']['basedir']}/server/etc/conf.d" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end


if platform_family?  "debian"
  runit_service "logstash_server"
elsif "rhel"
  template "/etc/init.d/logstash_server" do
    source "init.erb"
    owner "root"
    group "root"
    mode "0774"
  end
  service "logstash_server" do
    supports :restart => true, :reload => true, :status => true
    action :enable
  end
end

template "#{node['logstash']['basedir']}/server/etc/logstash.conf" do
  source node['logstash']['server']['base_config']
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0644"
  variables(:graphite_server_ip => graphite_server_ip,
            :es_server_ip => es_server_ip,
            :enable_embedded_es => node['logstash']['server']['enable_embedded_es'],
            :es_cluster => node['logstash']['elasticsearch_cluster'])
  notifies :restart, "service[logstash_server]"
  action :create
end

# stuff specific to management of logs from haproxy

directory "#{node['logstash']['basedir']}/server/apache_logs" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

link "/var/lib/logstash/apache_logs" do
  to "#{node['logstash']['basedir']}/server/apache_logs"
end

#create pattern_file  for haproxy
cookbook_file "/opt/logstash/server/etc/patterns/haproxy" do
    source "haproxy"
    owner node['logstash']['user']
    group node['logstash']['group']
    mode "0774"
end

#set logrotate  for /opt/logstash/server/apache_logs
logrotate_app "apache_logs" do
  path node['logstash']['server']['logrotate_target']
  frequency "daily"
  rotate "30"
  notifies :restart, "service[rsyslog]"
end


logrotate_app "logstash" do
  path "/var/log/logstash/*.log"
  frequency "daily"
  rotate "30"
  notifies :restart, "service[rsyslog]"
end



