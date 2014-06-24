# Encoding: utf-8
# rubocop:disable RedundantReturn

module Logstash
  def self.service_ip(node, instance = 'default', service = 'elasticsearch', interface = nil)
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
      service_query = attributes["#{service}_query"] || defaults["#{service}_query"]
      Chef::Search::Query.new.search(:node, service_query) { |o| results << o }
      if !results.empty?
        service_ip = get_ip_for_node(results[0], interface)
      else
        service_ip = attributes["#{service}_ip"] || defaults["#{service}_ip"]
      end
    end
  end

  def self.get_ip_for_node(node, interface)
    if interface.nil?
      service_ip = node['ipaddress']
    else
      service_ip = node['network']['interfaces'][interface]['addresses'].to_hash.find do
        |_, addr_info| addr_info['family'] == 'inet'
      end.first
    end
  end
end
