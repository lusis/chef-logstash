# Encoding: utf-8
#
# Cookbook Name:: logstash
# Recipe:: agent
#
#
include_recipe 'logstash::default'
include_recipe 'yum::default'

if node['logstash']['agent']['init_method'] == 'runit'
  include_recipe 'runit'
  service_resource = 'runit_service[logstash_agent]'
else
  service_resource = 'service[logstash_agent]'
end

if node['logstash']['agent']['patterns_dir'][0] == '/'
  patterns_dir = node['logstash']['agent']['patterns_dir']
else
  patterns_dir = node['logstash']['agent']['home'] + '/' + node['logstash']['agent']['patterns_dir']
end

if node['logstash']['install_zeromq']
  include_recipe 'logstash::zero_mq_repo'
  node['logstash']['zeromq_packages'].each { |p| package p }
end

# check if running chef-solo.  If not, detect the logstash server/ip by role.  If I can't do that, fall back to using ['logstash']['agent']['server_ipaddress']
if Chef::Config[:solo]
  logstash_server_ip = node['logstash']['agent']['server_ipaddress']
else
  logstash_server_results = search(:node, "roles:#{node['logstash']['agent']['server_role']}")
  if !logstash_server_results.empty?
    logstash_server_ip = logstash_server_results[0]['ipaddress']
  else
    logstash_server_ip = node['logstash']['agent']['server_ipaddress']
  end
end

directory node['logstash']['agent']['home'] do
  action :create
  mode '0755'
  owner node['logstash']['user']
  group node['logstash']['group']
end

%w{bin etc lib tmp log}.each do |ldir|
  directory "#{node['logstash']['agent']['home']}/#{ldir}" do
    action :create
    mode '0755'
    owner node['logstash']['user']
    group node['logstash']['group']
  end

  link "#{node['logstash']['homedir']}/#{ldir}" do
    to "#{node['logstash']['agent']['home']}/#{ldir}"
  end
end

directory "#{node['logstash']['agent']['home']}/etc/conf.d" do
  action :create
  mode '0755'
  owner node['logstash']['user']
  group node['logstash']['group']
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

if node['logstash']['agent']['install_method'] == 'jar'
  remote_file "#{node['logstash']['agent']['home']}/lib/logstash-#{node['logstash']['agent']['version']}.jar" do
    owner 'root'
    group 'root'
    mode '0755'
    source node['logstash']['agent']['source_url']
    checksum  node['logstash']['agent']['checksum']
    action :create_if_missing
  end

  link "#{node['logstash']['agent']['home']}/lib/logstash.jar" do
    to "#{node['logstash']['agent']['home']}/lib/logstash-#{node['logstash']['agent']['version']}.jar"
    notifies :restart, service_resource
  end
elsif node['logstash']['server']['install_method'] == 'repo'
    include_recipe 'logstash::repoinstall'
else
  include_recipe 'logstash::source'

  logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash']['server']['version']}"
  link "#{node['logstash']['agent']['home']}/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
    notifies :restart, service_resource
  end
end

template "#{node['logstash']['agent']['home']}/#{node['logstash']['agent']['config_dir']}/#{node['logstash']['agent']['config_file']}" do
  source node['logstash']['agent']['base_config']
  cookbook node['logstash']['agent']['base_config_cookbook']
  owner node['logstash']['user']
  group node['logstash']['group']
  mode '0644'
  variables(
          :logstash_server_ip => logstash_server_ip,
          :patterns_dir => patterns_dir)
  notifies :restart, service_resource
  only_if { node['logstash']['agent']['config_file'] }
end

unless node['logstash']['agent']['config_templates'].empty? || node['logstash']['agent']['config_templates'].nil?
  node['logstash']['agent']['config_templates'].each do |config_template|
    template "#{node['logstash']['agent']['home']}/#{node['logstash']['agent']['config_dir']}/#{config_template}.conf" do
      source "#{config_template}.conf.erb"
      cookbook node['logstash']['agent']['config_templates_cookbook']
      owner node['logstash']['user']
      group node['logstash']['group']
      mode '0644'
      variables node['logstash']['agent']['config_templates_variables'][config_template]
      notifies :restart, service_resource
      action :create
    end
  end
end

log_dir = ::File.dirname node['logstash']['agent']['log_file']
directory log_dir do
  action :create
  mode '0755'
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end

if node['logstash']['agent']['init_method'] == 'runit'
  runit_service 'logstash_agent'
elsif node['logstash']['agent']['init_method'] == 'native'
  if platform_family? 'debian'
    if node['platform_version'] >= '12.04'
      template '/etc/init/logstash_agent.conf' do
        mode '0644'
        source 'logstash_agent.conf.erb'
        notifies :restart, service_resource
      end

      service 'logstash_agent' do
        provider Chef::Provider::Service::Upstart
        action [:enable, :start]
      end
    else
      Chef::Log.fatal("Please set node['logstash']['agent']['init_method'] to 'runit' for #{node['platform_version']}")
    end
  elsif platform_family? 'fedora' && node['platform_version'] >= '15'
    execute 'reload-systemd' do
      command 'systemctl --system daemon-reload'
      action :nothing
    end

    template '/etc/systemd/system/logstash_agent.service' do
      source 'logstash_agent.service.erb'
      owner 'root'
      group 'root'
      mode  '0755'
      notifies :run, 'execute[reload-systemd]', :immediately
      notifies :restart, 'service[logstash_agent]', :delayed
    end

    service 'logstash_agent' do
      service_name 'logstash_agent.service'
      provider Chef::Provider::Service::Systemd
      action [:enable, :start]
    end
  elsif platform_family? 'rhel', 'fedora'
    template '/etc/init.d/logstash_agent' do
      source 'init.logstash_server.erb'
      owner 'root'
      group 'root'
      mode '0774'
      variables(
        :config_file => node['logstash']['agent']['config_dir'],
        :home => node['logstash']['agent']['home'],
        :log_file => node['logstash']['agent']['log_file'],
        :name => 'agent',
        :max_heap => node['logstash']['agent']['xmx'],
        :min_heap => node['logstash']['agent']['xms']
      )
    end

    service 'logstash_agent' do
      supports :restart => true, :reload => true, :status => true
      action :enable
    end
  end
else
  Chef::Log.fatal("Unsupported init method: #{node['logstash']['server']['init_method']}")
end

logrotate_app 'logstash' do
  path "#{log_dir}/*.log"
  if node['logstash']['logging']['useFileSize']
    size node['logstash']['logging']['maxSize']
  else
    frequency node['logstash']['logging']['rotateFrequency']
  end
  rotate node['logstash']['logging']['maxBackup']
  options node['logstash']['agent']['logrotate']['options']
  create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
  notifies :restart, 'service[rsyslog]'
  if node['logstash']['agent']['logrotate']['stopstartprepost']
    prerotate <<-EOF
      service logstash_agent stop
      logger stopped logstash_agent service for log rotation
    EOF
    postrotate <<-EOF
      service logstash_agent start
      logger started logstash_agent service after log rotation
    EOF
  end
end
