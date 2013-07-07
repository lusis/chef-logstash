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

include_recipe "rabbitmq" if node['logstash']['server']['install_rabbitmq']

if node['logstash']['install_zeromq']
  include_recipe "yumrepo::zeromq" if platform_family?("rhel")
  node['logstash']['zeromq_packages'].each {|p| package p }
end

if node['logstash']['server']['init_method'] == 'runit'
  include_recipe "runit"
  service_resource = 'runit_service[logstash_server]'
else
  service_resource = 'service[logstash_server]'
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
    notifies :restart, service_resource
  end
else
  include_recipe "logstash::source"

  logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash']['server']['version']}"
  link "#{node['logstash']['basedir']}/server/lib/logstash.jar" do
    to "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
    notifies :restart, service_resource
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
  notifies :restart, service_resource
  action :create
end

if node['logstash']['server']['init_method'] == 'runit'
  runit_service "logstash_server"
elsif node['logstash']['server']['init_method'] == 'native'
  if platform_family? "debian"
    if node["platform_version"] >= "12.04"
      template "/etc/init/logstash_server.conf" do
        mode "0644"
        source "logstash_server.conf.erb"
      end

      service "logstash_server" do
        provider Chef::Provider::Service::Upstart
        action [ :enable, :start ]
      end
    else
      Chef::Log.fatal("Please set node['logstash']['server']['init_method'] to 'runit' for #{node['platform_version']}")
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

  elsif platform_family? "smartos", "solaris2"
    logstash_home = "#{node['logstash']['basedir']}/server"
    logstash_opts = "agent -f #{logstash_home}/etc/logstash.conf " <<
      "-l #{node['logstash']['log_dir']}/logstash.log"
    java_opts = "-server -Xms#{node['logstash']['server']['xms']} " <<
      "-Xmx#{node['logstash']['server']['xmx']} " <<
      "-Djava.io.tmpdir=#{logstash_home}/tmp/ " <<
      "#{node['logstash']['server']['java_opts']} " <<
      "#{'-Djava.net.preferIPv4Stack=true' if node['logstash']['agent']['ipv4_only']}"
    gc_opts = node['logstash']['server']['gc_opts']

    smf "logstash_server" do
      user node['logstash']['user']
      start_command "java #{java_opts} #{gc_opts} -jar #{logstash_home}/lib/logstash.jar #{logstash_opts}"
      start_timeout 30
      stop_command ':kill'
      stop_timeout 30
      restart_command ':kill -SIGHUP'
      restart_timeout 30
      environment(
        'LOGSTASH_HOME' => logstash_home,
        'HOME' => logstash_home,
        'GC_OPTS' => gc_opts,
        'JAVA_OPTS' => java_opts,
        'LOGSTASH_OPTS' => logstash_opts,
      )
      locale "C"
      manifest_type "application"
      service_path "/var/svc/manifest"
    end

    service "logstash_server" do
      supports :restart => true, :reload => true, :status => true
      action [:enable, :start]
    end
  end
else
  Chef::Log.fatal("Unsupported init method: #{node['logstash']['server']['init_method']}")
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
  options node['logstash']['server']['logrotate']['options']
  create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
  not_if { platform_family? "smartos", "solaris2" }
end

if platform_family? "smartos", "solaris2"
  logadm "logstash_server" do
    path "#{node['logstash']['log_dir']}/*.log"
    period "1d"
    size "1b"
    count "30"
    copy true
    gzip true
  end
end
