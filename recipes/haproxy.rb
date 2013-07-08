# this recipe lets output haproxy logs to file as if they were apache
# virtual logs, in order to interface with legacy traffic measuring
# applications like AWstats
# Also requires changes to your haproxy configuration
# and a file output on your logstash_server
# I have no idea if it meets anyone's needs other than my own
# only for those crazy enough to replace apache or Nginx as their
# main front-end server - Bryan W. Berry 28 June 2012

unless platform_family?('smartos', 'solaris2')
  include_recipe "logrotate"
else
  include_recipe "logadm"
end

directory "#{node['logstash']['basedir']}/server/apache_logs" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

link "#{node['logstash']['user_home']}/apache_logs" do
  to "#{node['logstash']['basedir']}/server/apache_logs"
end

directory "/opt/logstash/server/etc/patterns" do
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0774"
end

# create pattern_file  for haproxy
cookbook_file "/opt/logstash/server/etc/patterns/haproxy" do
  source "haproxy"
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0774"
end

unless platform_family?('smartos', 'solaris2')
  # set logrotate  for /opt/logstash/server/apache_logs
  logrotate_app "apache_logs" do
    path node['logstash']['server']['logrotate_target']
    frequency "daily"
    create    "664 #{node['logstash']['user']} #{node['logstash']['user']}"
    rotate "30"
  end
end
