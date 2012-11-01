#
# Cookbook Name:: logstash
# Recipe:: agent
#
#
include_recipe "logstash::default"

# check if running chef-solo.  If not, detect the logstash server/ip by role.  If I can't do that, fall back to using ['logstash']['agent']['server_ipaddress']
if Chef::Config[:solo]
  logstash_server_ip = node['logstash']['agent']['server_ipaddress']
else
  logstash_server_results = search(:node, "roles:#{node['logstash']['agent']['server_role']}")
  unless logstash_server_results.empty?
    logstash_server_ip = logstash_server_results[0]['ipaddress']
  else
    logstash_server_ip = node['logstash']['agent']['server_ipaddress']
  end
end

directory "#{node['logstash']['basedir']}/agent" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

%w{bin etc lib tmp log}.each do |ldir|
  directory "#{node['logstash']['basedir']}/agent/#{ldir}" do
    action :create
    mode "0755"
    owner node['logstash']['user']
    group node['logstash']['group']
  end

  link "/var/lib/logstash/#{ldir}" do
    to "#{node['logstash']['basedir']}/agent/#{ldir}"
  end
end

directory "#{node['logstash']['basedir']}/agent/etc/conf.d" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

directory "#{node['logstash']['basedir']}/agent/etc/patterns" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

if platform?  "debian", "ubuntu"
  if node["platform_version"] == "12.04"
    template "/etc/init/logstash_agent.conf" do
      mode "0644"
      source "logstash_agent.conf.erb"
    end

    service "logstash_agent" do
      provider Chef::Provider::Service::Upstart
      action [ :enable, :start ]
    end
  else
    runit_service "logstash_agent"
  end
elsif platform? "redhat", "centos", "amazon", "fedora"
  template "/etc/init.d/logstash_agent" do
    source "init.erb"
    owner "root"
    group "root"
    mode "0774"
    variables(
      :config_file => "shipper.conf",
      :basedir => "#{node['logstash']['basedir']}/agent"
    )
  end

  service "logstash_agent" do
    supports :restart => true, :reload => true, :status => true
    action :enable
  end
end

if node['logstash']['agent']['install_method'] == "jar"
  remote_file "#{node['logstash']['basedir']}/agent/lib/logstash-#{node['logstash']['agent']['version']}.jar" do
    owner "root"
    group "root"
    mode "0755"
    source node['logstash']['agent']['source_url']
    checksum  node['logstash']['agent']['checksum']
  end

  link "#{node['logstash']['basedir']}/agent/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/agent/lib/logstash-#{node['logstash']['agent']['version']}.jar"
    notifies :restart, "service[logstash_agent]"
  end
else
  include_recipe "logstash::source"

  link "#{node['logstash']['basedir']}/agent/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{node['logstash']['source']['sha']}-monolithic.jar"
    notifies :restart, "service[logstash_agent]"
  end
end

template "#{node['logstash']['basedir']}/agent/etc/shipper.conf" do
  source node['logstash']['agent']['base_config']
  cookbook node['logstash']['agent']['base_config_cookbook']
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0644"
  variables(:logstash_server_ip => logstash_server_ip)
  notifies :restart, "service[logstash_agent]"
end

directory node['logstash']['log_dir'] do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end

logrotate_app "logstash" do
  path "#{node['logstash']['log_dir']}/*.log"
  frequency "daily"
  rotate "30"
  create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
  notifies :restart, "service[rsyslog]"
end

