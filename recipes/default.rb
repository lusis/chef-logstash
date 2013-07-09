#
# Cookbook Name:: logstash
# Recipe:: default
#
unless platform_family?('smartos', 'solaris2') || node["platform_version"] >= "12.04"
  include_recipe "runit"
end
include_recipe "java"

if node['logstash']['create_account']

  # There's something up with `groupadd` options that assumes GNU or some such
  group node['logstash']['group'] do
    system !platform_family?('smartos', 'solaris2')
    gid 16345 # first 5 of 'logstash' md5
  end

  directory File.dirname(node['logstash']['user_home']) do
    mode 0755
    recursive true
  end

  user node['logstash']['user'] do
    group node['logstash']['group']
    home node['logstash']['user_home']
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

