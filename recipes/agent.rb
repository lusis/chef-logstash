#
# Cookbook Name:: logstash
# Recipe:: agent
#
#
include_recipe "logstash::default"

if node['logstash']['agent']['init_method'] == 'runit'
  include_recipe "runit"
  service_resource = 'runit_service[logstash_agent]'
else
  service_resource = 'service[logstash_agent]'
end

if node['logstash']['agent']['patterns_dir'][0] == '/'
  patterns_dir = node['logstash']['agent']['patterns_dir']
else
  patterns_dir = node['logstash']['basedir'] + '/' + node['logstash']['agent']['patterns_dir']
end

if node['logstash']['install_zeromq']
  case
  when platform_family?("rhel")
    include_recipe "yumrepo::zeromq"
  when platform_family?("debian")
    apt_repository "zeromq-ppa" do
      uri "http://ppa.launchpad.net/chris-lea/zeromq/ubuntu"
      distribution node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "C7917B12"
      action :add
    end
    apt_repository "libpgm-ppa" do
      uri "http://ppa.launchpad.net/chris-lea/libpgm/ubuntu"
      distribution  node['lsb']['codename']
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "C7917B12"
      action :add
      notifies :run, "execute[apt-get update]", :immediately
    end
  end
  node['logstash']['zeromq_packages'].each {|p| package p }
end

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
    variables( :patterns => hash )
    mode '0644'
    notifies :restart, service_resource
  end
end

directory node['logstash']['log_dir'] do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end

if node['logstash']['agent']['init_method'] == 'runit'
  runit_service "logstash_agent"
elsif node['logstash']['agent']['init_method'] == 'native'
  if platform_family? "debian"
    if ["12.04", "12.10", "13.04"].include? node["platform_version"]
      template "/etc/init/logstash_agent.conf" do
        mode "0644"
        source "logstash_agent.conf.erb"
        notifies :restart, service_resource
      end

      service "logstash_agent" do
        provider Chef::Provider::Service::Upstart
        action [ :enable, :start ]
      end
    else
      Chef::Log.fatal("Please set node['logstash']['agent']['init_method'] to 'runit' for #{node['platform_version']}")
    end
  elsif platform_family? "rhel", "fedora"
    template "/etc/init.d/logstash_agent" do
      source "init.erb"
      owner "root"
      group "root"
      mode "0774"
      variables(
        :config_file => "shipper.conf",
        :name => 'agent',
        :max_heap => node['logstash']['agent']['xmx'],
        :min_heap => node['logstash']['agent']['xms']
      )
    end

    service "logstash_agent" do
      supports :restart => true, :reload => true, :status => true
      action :enable
    end
  end
else
  Chef::Log.fatal("Unsupported init method: #{node['logstash']['server']['init_method']}")
end

if node['logstash']['agent']['install_method'] == "jar"
  remote_file "#{node['logstash']['basedir']}/agent/lib/logstash-#{node['logstash']['agent']['version']}.jar" do
    owner "root"
    group "root"
    mode "0755"
    source node['logstash']['agent']['source_url']
    checksum  node['logstash']['agent']['checksum']
    action :create_if_missing
  end

  link "#{node['logstash']['basedir']}/agent/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/agent/lib/logstash-#{node['logstash']['agent']['version']}.jar"
    notifies :restart, "service[logstash_agent]"
  end
else
  include_recipe "logstash::source"

  logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash']['server']['version']}"
  link "#{node['logstash']['basedir']}/agent/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
    notifies :restart, "service[logstash_agent]"
  end
end

template "#{node['logstash']['basedir']}/agent/etc/shipper.conf" do
  source node['logstash']['agent']['base_config']
  cookbook node['logstash']['agent']['base_config_cookbook']
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0644"
  variables(
            :logstash_server_ip => logstash_server_ip,
            :patterns_dir => patterns_dir)
  notifies :restart, "service[logstash_agent]"
end

logrotate_app "logstash" do
  path "#{node['logstash']['log_dir']}/*.log"
  frequency "daily"
  rotate "30"
  options node['logstash']['agent']['logrotate']['options']
  create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
  notifies :restart, "service[rsyslog]"
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

