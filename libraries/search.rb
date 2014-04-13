# Encoding: utf-8
# rubocop:disable RedundantReturn
require 'rubygems'

# extend recipe class for library
class Chef
  class Recipe
    def service_ip(instance = 'default', service = 'elasticsearch')
      if node['logstash']['instance'].key?(instance)
        attributes = node['logstash']['instance'][instance]
        defaults = node['logstash']['instance'][instance]
      else
        attributes = node['logstash']['instance']['default']
      end
      if Chef::Config[:solo]
        service_ip = attributes["#{service}_ip"] || defaults["#{service}_ip"]
        service_query = attributes["#{service}_query"] || defaults["#{service}_query"]
      else
        results = search(:node, service_query)
        if !results.empty?
          service_ip = results[0]['ipaddress']
        else
          service_ip = attributes["#{service}_ip"] || defaults["#{service}_ip"]
        end
      end
      service_ip
    end
  end
end
