# Encoding: utf-8
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

if Chef::Config[:solo]
  es_server_ip = node['logstash']['elasticsearch_ip']
  graphite_server_ip = node['logstash']['graphite_ip']
else
  es_results = search(:node, node['logstash']['elasticsearch_query'])
  graphite_results = search(:node, node['logstash']['graphite_query'])

  if !es_results.empty?
    es_server_ip = es_results[0]['ipaddress']
  else
    es_server_ip = node['logstash']['elasticsearch_ip']
  end

  if !graphite_results.empty?
    graphite_server_ip = graphite_results[0]['ipaddress']
  else
    graphite_server_ip = node['logstash']['graphite_ip']
  end
end

conf_variables = {
  :graphite_server_ip => graphite_server_ip,
  :es_server_ip => es_server_ip,
  :enable_embedded_es => node['logstash']['server']['enable_embedded_es'],
  :es_cluster => node['logstash']['elasticsearch_cluster'],
}

services = ['server']
services << 'web' if node['logstash']['server']['web']['enable']

instance 'server' do
  services services
  conf_variables conf_variables
end
