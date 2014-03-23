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

# install logstash 'server'

name = 'server'
attributes = node['logstash']['instance'][name]

# these should all default correctly.  listing out for example.
logstash_instance name do
  action            :create
end

# services are hard! Let's go LWRP'ing.   FIREBALL! FIREBALL! FIREBALL!
logstash_service name do
  action      [:enable, :start]
end

es_ip = service_ip(name, 'elasticsearch')

logstash_config name do
  action [:create]
  variables(
      elasticsearch_ip: es_ip,
      elasticsearch_embedded: true
  )
end

logstash_pattern name do
  action [:create]
end
