# Encoding: utf-8
# rubocop:disable RedundantReturn

module Logstash
  def self.service_ip(node, instance = 'default', service = 'elasticsearch')
    if node['logstash']['instance'].key?(instance)
      attributes = node['logstash']['instance'][instance]
      defaults = node['logstash']['instance']['default']
    else
      attributes = node['logstash']['instance']['default']
    end
    if Chef::Config[:solo]
      service_ip = attributes["#{service}_ip"] || defaults["#{service}_ip"]
    else
      results = []
      Chef::Search::Query.new.search(:node, service_query) { |o| results << o }
      if !results.empty?
        service_ip = results[0]['ipaddress']
      else
        service_ip = attributes["#{service}_ip"] || defaults["#{service}_ip"]
      end
    end
  end
end
