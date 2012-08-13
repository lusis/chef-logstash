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
include_recipe "rabbitmq"

if Chef::Config[:solo] 
  es_server_ip = node['logstash']['elasticsearch_ip']
  graphite_server_ip = node['logstash']['graphite_ip']
else
  es_results = search(:node, "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}")
  graphite_results = search(:node, "roles:#{node['logstash']['graphite_role']} AND chef_environment:#{node.chef_environment}")

  unless es_results.empty?
    es_server_ip = es_results[0]['ipaddress']
  else
    es_server_ip = node['logstash']['elasticsearch_ip']
  end
  unless graphite_results.empty?
    graphite_server_ip = graphite_results[0]['ipaddress']
  else
    graphite_server_ip = node['logstash']['graphite_ip']
  end
end

#create directory for logstash
directory "#{node['logstash']['basedir']}/server" do
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


if platform?  "debian", "ubuntu"
  if node["platform_version"] == "12.04"
    template "/etc/init/logstash_server.conf" do
      mode "0644"
      source "logstash_server.conf.erb"
    end
    service "logstash_server" do
      provider Chef::Provider::Service::Upstart
      action [ :enable, :start ]
    end
  else
    runit_service "logstash_server"
  end
elsif platform? "redhat", "centos","amazon", "fedora"
  template "/etc/init.d/logstash_server" do
    source "init.erb"
    owner "root"
    group "root"
    mode "0774"
    variables(
              :config_file => "logstash.conf",
              :basedir => "#{node['logstash']['basedir']}/server"
              )
  end
  service "logstash_server" do
    supports :restart => true, :reload => true, :status => true
    action :enable
  end
end

template "#{node['logstash']['basedir']}/server/etc/logstash.conf" do
  source node['logstash']['server']['base_config']
  cookbook node['logstash']['server']['base_config_cookbook']
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

cron "compress and remove logs rotated by log4j" do
  minute "0"
  hour   "0"
  command  "find /var/log/logstash -name '*.gz' -mtime +30 -exec rm -f '{}' \\; ; \
  find /var/log/logstash ! -name '*.gz' -mtime +2 -exec gzip '{}' \\;"
end

