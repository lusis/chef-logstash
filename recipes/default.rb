#
# Cookbook Name:: logstash
# Recipe:: default
#
include_recipe "runit"
include_recipe "java"

group "#{node[:logstash][:group]}" do
  system true
end

user "#{node[:logstash][:user]}" do
  group "#{node[:logstash][:group]}"
  home "/var/lib/logstash"
  system true
  action :create
  manage_home true
end

directory "#{node[:logstash][:basedir]}" do
  action :create
  owner "root"
  group "root"
  mode "0755"
end
