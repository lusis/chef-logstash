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

include_recipe "rabbitmq" if node['logstash']['server']['install_rabbitmq']

if node['logstash']['install_zeromq']
  include_recipe "yumrepo::zeromq" if platform_family?("rhel")
  node['logstash']['zeromq_packages'].each {|p| package p }
end

if node['logstash']['server']['patterns_dir'][0] == '/'
  patterns_dir = node['logstash']['server']['patterns_dir']
else
  patterns_dir = node['logstash']['basedir'] + '/' + node['logstash']['server']['patterns_dir']
end

if Chef::Config[:solo]
  es_server_ip = node['logstash']['elasticsearch_ip']
  graphite_server_ip = node['logstash']['graphite_ip']
else
  es_results = search(:node, node['logstash']['elasticsearch_query'])
  graphite_results = search(:node, node['logstash']['graphite_query'])

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

# Create directory for logstash
directory "#{node['logstash']['basedir']}/server" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

%w{bin etc lib log tmp }.each do |ldir|
  directory "#{node['logstash']['basedir']}/server/#{ldir}" do
    action :create
    mode "0755"
    owner node['logstash']['user']
    group node['logstash']['group']
  end
end

# installation
if node['logstash']['server']['install_method'] == "jar"
  remote_file "#{node['logstash']['basedir']}/server/lib/logstash-#{node['logstash']['server']['version']}.jar" do
    owner "root"
    group "root"
    mode "0755"
    source node['logstash']['server']['source_url']
    checksum node['logstash']['server']['checksum']
    action :create_if_missing
  end

  link "#{node['logstash']['basedir']}/server/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/server/lib/logstash-#{node['logstash']['server']['version']}.jar"
    notifies :restart, "service[logstash_server]"
  end
else
  include_recipe "logstash::source"

  logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash']['server']['version']}"
  link "#{node['logstash']['basedir']}/server/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
    notifies :restart, "service[logstash_server]"
  end
end

directory "#{node['logstash']['basedir']}/server/etc/conf.d" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

directory patterns_dir do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

node['logstash']['patterns'].each do |file, hash|
  template_name = patterns_dir + '/' + file
  template template_name do
    source 'patterns.erb'
    owner node['logstash']['user']
    group node['logstash']['group']
    variables(:patterns => hash)
    mode '0644'
    notifies :restart, 'service[logstash_server]'
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
            :es_cluster => node['logstash']['elasticsearch_cluster'],
            :patterns_dir => patterns_dir)
  notifies :restart, "service[logstash_server]"
  action :create
end

if platform_family? "debian"
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
elsif platform_family? "rhel","fedora"
  template "/etc/init.d/logstash_server" do
    source "init.erb"
    owner "root"
    group "root"
    mode "0774"
    variables(:config_file => "logstash.conf",
              :name => 'server',
              :max_heap => node['logstash']['server']['xmx'],
              :min_heap => node['logstash']['server']['xms']
              )
  end

  service "logstash_server" do
    supports :restart => true, :reload => true, :status => true
    action [:enable, :start]
  end
end

directory node['logstash']['log_dir'] do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end

logrotate_app "logstash_server" do
  path "#{node['logstash']['log_dir']}/*.log"
  frequency "daily"
  rotate "30"
  options [ "missingok", "notifempty" ]
  create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
end

