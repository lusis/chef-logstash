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

include_recipe 'java'
include_recipe 'logstash::default'
include_recipe 'logrotate'

include_recipe 'rabbitmq' if node['logstash']['install_rabbitmq']

if node['logstash']['install_zeromq']
  include_recipe 'logstash::zero_mq_repo'
  node['logstash']['zeromq_packages'].each { |p| package p }
end

if node['logstash']['server']['install_method'] == 'repo'
  service_resource = 'service[logstash]'
elsif node['logstash']['server']['init_method'] == 'runit'
  include_recipe 'runit'
  service_resource = 'runit_service[logstash_server]'
else
  service_resource = 'service[logstash_server]'
end

if node['logstash']['server']['patterns_dir'][0] == '/'
  patterns_dir = node['logstash']['server']['patterns_dir']
else
  patterns_dir = node['logstash']['server']['home'] + '/' + node['logstash']['server']['patterns_dir']
end

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

# Create directory for logstash
if node['logstash']['server']['install_method'] != 'repo'
	directory node['logstash']['server']['home'] do
	  action :create
	  mode '0755'
	  owner node['logstash']['user']
	  group node['logstash']['group']
	end
	
	%w{bin etc lib log tmp }.each do |ldir|
	  directory "#{node['logstash']['server']['home']}/#{ldir}" do
	    action :create
	    mode '0755'
	    owner node['logstash']['user']
	    group node['logstash']['group']
	  end
	end
end
	
# installation
if node['logstash']['server']['install_method'] == 'jar'
  remote_file "#{node['logstash']['server']['home']}/lib/logstash-#{node['logstash']['server']['version']}.jar" do
    owner 'root'
    group 'root'
    mode '0755'
    source node['logstash']['server']['source_url']
    checksum node['logstash']['server']['checksum']
    action :create_if_missing
  end

  link "#{node['logstash']['server']['home']}/lib/logstash.jar" do
    to "#{node['logstash']['server']['home']}/lib/logstash-#{node['logstash']['server']['version']}.jar"
    notifies :restart, service_resource
  end
elsif node['logstash']['server']['install_method'] == 'repo'
    include_recipe 'logstash::repoinstall'
else
  include_recipe 'logstash::source'

  logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash']['server']['version']}"
  link "#{node['logstash']['server']['home']}/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
    notifies :restart, service_resource
  end
end

if node['logstash']['server']['install_method'] != 'repo'
	directory "#{node['logstash']['server']['home']}/etc/conf.d" do
	  action :create
	  mode '0755'
	  owner node['logstash']['user']
	  group node['logstash']['group']
	end
end

directory patterns_dir do
  action :create
  mode '0755'
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
    notifies :restart, service_resource
  end
end

log_dir = ::File.dirname node['logstash']['server']['log_file']
directory log_dir do
  action :create
  mode '0755'
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end

if node['logstash']['server']['install_method'] == 'repo'
    config_dir = "#{node['logstash']['server']['config_dir']}"
else
    config_dir = "#{node['logstash']['server']['home']}/#{node['logstash']['server']['config_dir']}"
end

template "#{config_dir}/#{node['logstash']['server']['config_file']}" do
  source node['logstash']['server']['base_config']
  cookbook node['logstash']['server']['base_config_cookbook']
  owner node['logstash']['user']
  group node['logstash']['group']
  mode '0644'
  variables(
            :graphite_server_ip => graphite_server_ip,
            :es_server_ip => es_server_ip,
            :enable_embedded_es => node['logstash']['server']['enable_embedded_es'],
            :es_cluster => node['logstash']['elasticsearch_cluster'],
            :patterns_dir => patterns_dir
            )
  notifies :restart, service_resource
  action :create
  only_if { node['logstash']['server']['config_file'] }
end

unless node['logstash']['server']['config_templates'].empty? || node['logstash']['server']['config_templates'].nil?
  node['logstash']['server']['config_templates'].each do |config_template|
    template "#{config_dir}/#{config_template}.conf" do
      source "#{config_template}.conf.erb"
      cookbook node['logstash']['server']['config_templates_cookbook']
      owner node['logstash']['user']
      group node['logstash']['group']
      mode '0644'
      variables node['logstash']['server']['config_templates_variables'][config_template]
      notifies :restart, service_resource
      action :create
    end
  end
end

if node['logstash']['server']['install_method'] != 'repo'
	services = ['server']
	services << 'web' if node['logstash']['server']['web']['enable']
	
	services.each do |type|
	  if node['logstash']['server']['init_method'] == 'runit'
	    runit_service("logstash_#{type}")
	  elsif node['logstash']['server']['init_method'] == 'native'
	    if platform_family? 'debian'
	      if node['platform_version'] >= '12.04'
	        template "/etc/init/logstash_#{type}.conf" do
	          mode '0644'
	          source "logstash_#{type}.conf.erb"
	        end
	
	        service "logstash_#{type}" do
	          provider Chef::Provider::Service::Upstart
	          action [:enable, :start]
	        end
	      else
	        Chef::Log.fatal("Please set node['logstash']['server']['init_method'] to 'runit' for #{node['platform_version']}")
	      end
	
	    elsif platform_family? 'fedora' && node['platform_version'] >= '15'
	      execute 'reload-systemd' do
	        command 'systemctl --system daemon-reload'
	        action :nothing
	      end
	
	      template '/etc/systemd/system/logstash_server.service' do
	        source 'logstash_server.service.erb'
	        owner 'root'
	        group 'root'
	        mode  '0755'
	        notifies :run, 'execute[reload-systemd]', :immediately
	        notifies :restart, 'service[logstash_server]', :delayed
	      end
	
	      service 'logstash_server' do
	        service_name 'logstash_server.service'
	        provider Chef::Provider::Service::Systemd
	        action [:enable, :start]
	      end
	
	    elsif platform_family? 'rhel', 'fedora'
	      template "/etc/init.d/logstash_#{type}" do
	        source "init.logstash_#{type}.erb"
	        owner 'root'
	        group 'root'
	        mode '0774'
	        variables(:config_file => node['logstash']['server']['config_dir'],
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
else
    service "logstash" do
        service_name 'logstash'
        supports :restart => true, :reload => true, :status => true
        action [:enable, :start]
    end
end

logrotate_app 'logstash_server' do
  path "#{log_dir}/*.log"
  size node['logstash']['logging']['maxSize'] if node['logstash']['logging']['useFileSize']
  frequency node['logstash']['logging']['rotateFrequency']
  rotate node['logstash']['logging']['maxBackup']
  options node['logstash']['server']['logrotate']['options']
  create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
end
