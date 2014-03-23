# Encoding: utf-8
# rubocop:disable RedundantReturn
require 'rubygems'

# extend recipe class for library
class Chef
  class Recipe
    def service_ip(instance = 'default', service = 'elasticsearch')
      if node['logstash']['instance'].key?(instance)
        attributes = node['logstash']['instance'][instance]
      else
        attributes = node['logstash']['instance']['default']
      end
      if Chef::Config[:solo]
        service_ip = attributes["#{service}_ip"]
      else
        results = search(:node, attributes["#{service}_query"])
        if !results.empty?
          service_ip = results[0]['ipaddress']
        else
          service_ip = attributes["#{service}_ip"]
        end
      end
      service_ip
    end
  end
end
