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

include_recipe "java"
include_recipe "logstash::default"
include_recipe "logrotate"

include_recipe "rabbitmq" if node['logstash']['install_rabbitmq']

if node['logstash']['install_zeromq']
  include_recipe "yumrepo::zeromq" if platform_family?("rhel")
  node['logstash']['zeromq_packages'].each {|p| package p }
end

include_recipe 'runit' if node['logstash']['server']['init_method'] == 'runit'
service_resource = node['logstash']['server']['init_notify']

# Create directory for logstash
directory node['logstash']['server']['home'] do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

%w{bin etc lib log tmp }.each do |ldir|
  directory "#{node['logstash']['server']['home']}/#{ldir}" do
    action :create
    mode "0755"
    owner node['logstash']['user']
    group node['logstash']['group']
  end
end

# installation
if node['logstash']['server']['install_method'] == "jar"
  remote_file "#{node['logstash']['server']['home']}/lib/logstash-#{node['logstash']['server']['version']}.jar" do
    owner "root"
    group "root"
    mode "0755"
    source node['logstash']['server']['source_url']
    checksum node['logstash']['server']['checksum']
    action :create_if_missing
  end

  link "#{node['logstash']['server']['home']}/lib/logstash.jar" do
    to "#{node['logstash']['server']['home']}/lib/logstash-#{node['logstash']['server']['version']}.jar"
    notifies :restart, service_resource
  end
else
  include_recipe "logstash::source"

  logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash']['server']['version']}"
  link "#{node['logstash']['server']['home']}/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
    notifies :restart, service_resource
  end
end


node['logstash']['server']['dirs'].each do |name, config|
  attributes = node['logstash']['server']['dir_defaults'].merge(config)

  directory name do
    attributes.each do |key, values|
      send(key, *values)
    end
  end
end

node['logstash']['patterns'].each do |file, hash|
  template_name =
    File.join(node['logstash']['server']['dirs']['patterns']['path'], file)
  template template_name do
    source 'patterns.erb'
    owner node['logstash']['user']
    group node['logstash']['group']
    variables(:patterns => hash)
    mode '0644'
    notifies :restart, service_resource
  end
end

if node['logstash']['server']['templates'].empty?
  unless Chef::Config[:solo]
    es_results       = search(:node, node['logstash']['elasticsearch_query'])
    graphite_results = search(:node, node['logstash']['graphite_query'])

    @elasticsearch_ip = es_results[0]['ipaddress'] if es_results.any?
    @graphite_ip      = graphite_results[0]['ipaddress'] if graphite_results.any?
  end

  default['logstash']['server']['templates']['server'] = {
    source: 'server.conf.erb',
    path: File.join(node['logstash']['server']['dirs']['config']['path'], 'server.conf'),
    variables: [{
      graphite_server_ip: @graphite_ip || node['logstash']['graphite_ip'],
      es_server_ip: @elasticsearch_ip || node['logstash']['elasticsearch_ip'],
      enable_embedded_es: node['logstash']['server']['enable_embedded_es'],
      es_cluster: node['logstash']['elasticsearch_cluster'],
      patterns_dir: node['logstash']['server']['dirs']['patterns']['path']
    }]
  }
end

node['logstash']['server']['templates'].each do |name, config|
  directory File.dirname(config['path']) do
    node['logstash']['server']['dir_defaults'].each do |key, values|
      send(key, *values)
    end
  end

  attributes = node['logstash']['server']['template_defaults'].merge(config)

  template name do
    attributes.each do |key, values|
      send(key, *values)
    end

    source "#{name}.conf.erb" unless attributes.key?('source')
  end
end

services = ['server']
services << 'web' if node['logstash']['server']['web']['enable']

services.each do |type|
  if node['logstash']['server']['init_method'] == 'runit'
    runit_service("logstash_#{type}")
  elsif node['logstash']['server']['init_method'] == 'native'
    if platform_family? "debian"
      if node["platform_version"] >= "12.04"
        template "/etc/init/logstash_#{type}.conf" do
          mode "0644"
          source "logstash_#{type}.conf.erb"
        end

        service "logstash_#{type}" do
          provider Chef::Provider::Service::Upstart
          action [:enable, :start]
        end
      else
        Chef::Log.fatal("Please set node['logstash']['server']['init_method'] to 'runit' for #{node['platform_version']}")
      end
    elsif platform_family? "rhel","fedora"
      template "/etc/init.d/logstash_#{type}" do
        source "init.logstash_#{type}.erb"
        owner 'root'
        group 'root'
        mode '0774'
        variables(:config_file => node['logstash']['server']['dirs']['config']['path'],
                  :home => node['logstash']['server']['home'],
                  :name => type,
                  :log_file => node['logstash']['server']['log_file'],
                  :max_heap => node['logstash']['server']['xmx'],
                  :min_heap => node['logstash']['server']['xms']
                  )
      end

      service "logstash_#{type}" do
        supports :restart => true, :reload => true, :status => true
        action [:enable, :start]
      end
    end
  else
    Chef::Log.fatal("Unsupported init method: #{node['logstash']['server']['init_method']}")
  end
end

logrotate_app "logstash_server" do
  path File.join(File.dirname(node['logstash']['server']['log_file']), '*.log')
  if node['logstash']['logging']['useFileSize']
    size node['logstash']['logging']['maxSize']
  end
  frequency node['logstash']['logging']['rotateFrequency']
  rotate node['logstash']['logging']['maxBackup']
  options node['logstash']['server']['logrotate']['options']
  create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
end
