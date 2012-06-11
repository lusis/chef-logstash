#
# Cookbook Name:: logstash
# Recipe:: server
#
#
include_recipe "logstash::default"

graphite_server = search(:node, "role:#{node[:logstash][:graphite_role]} AND chef_environment:#{node.chef_environment}")
elasticsearch_server = search(:node, "role:#{node[:logstash][:elasticsearch_role]} AND chef_environment:#{node.chef_environment}")

directory "#{node[:logstash][:basedir]}/server" do
  action :create
  mode "0755"
  owner "#{node[:logstash][:user]}"
  group "#{node[:logstash][:group]}"
end

%w{bin etc lib log tmp}.each do |ldir|
  directory "#{node[:logstash][:basedir]}/server/#{ldir}" do
    action :create
    mode "0755"
    owner "#{node[:logstash][:user]}"
    group "#{node[:logstash][:group]}"
  end

  link "/var/lib/logstash/#{ldir}" do
    to "#{node[:logstash][:basedir]}/server/#{ldir}"
  end
end

directory "#{node[:logstash][:basedir]}/server/etc/conf.d" do
  action :create
  mode "0755"
  owner "#{node[:logstash][:user]}"
  group "#{node[:logstash][:group]}"
end

directory "#{node[:logstash][:basedir]}/server/etc/patterns" do
  action :create
  mode "0755"
  owner "#{node[:logstash][:user]}"
  group "#{node[:logstash][:group]}"
end

if node[:logstash][:server][:install_method] == "jar"
  remote_file "#{node[:logstash][:basedir]}/server/lib/logstash-#{node[:logstash][:server][:version]}.jar" do
    owner "root"
    group "root"
    mode "0755"
    source "#{node[:logstash][:server][:source_url]}"
    checksum "#{node[:logstash][:server][:checksum]}"
  end
  link "#{node[:logstash][:basedir]}/server/lib/logstash.jar" do
    to "#{node[:logstash][:basedir]}/server/lib/logstash-#{node[:logstash][:server][:version]}.jar"
    notifies :restart, "service[logstash_server]"
  end
else
  include_recipe "logstash::source"

  link "#{node[:logstash][:basedir]}/server/lib/logstash.jar" do
    to "#{node[:logstash][:basedir]}/source/build/logstash-#{node[:logstash][:source][:sha]}-monolithic.jar"
    notifies :restart, "service[logstash_server]"
  end
end

template "#{node[:logstash][:basedir]}/server/etc/logstash.conf" do
  source "#{node[:logstash][:server][:base_config]}"
  owner "#{node[:logstash][:user]}"
  group "#{node[:logstash][:group]}"
  mode "0644"
  variables(:graphite_server => graphite_server,
            :enable_embedded_es => node[:logstash][:server][:enable_embedded_es],
            :es_server => elasticsearch_server,
            :es_cluster => node[:logstash][:elasticsearch_cluster])
  notifies :restart, "service[logstash_server]"
end

runit_service "logstash_server"
