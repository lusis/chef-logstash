#
# Cookbook Name:: logstash
# Recipe:: default
#
include_recipe "runit" unless node["platform_version"] == "12.04"
include_recipe "java"

if node['logstash']['create_account']

  group node['logstash']['group'] do
    system true
  end

  user node['logstash']['user'] do
    group node['logstash']['group']
    home "/var/lib/logstash"
    system true
    action :create
    manage_home true
  end

end

directory node['logstash']['basedir'] do
  action :create
  owner "root"
  group "root"
  mode "0755"
end

node['logstash']['join_groups'].each do |grp|
  group grp do
    members node['logstash']['user']
    action :modify
    append true
    only_if "grep -q '^#{grp}:' /etc/group"
  end
end

