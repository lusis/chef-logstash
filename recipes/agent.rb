# Encoding: utf-8
#
# Cookbook Name:: logstash
# Recipe:: agent
#
#

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

conf_variables = {
  :logstash_server_ip => logstash_server_ip,
}

services = ['agent']

instance 'agent' do
  services services
  conf_variables conf_variables
end

