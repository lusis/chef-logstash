# Encoding: utf-8
# rubocop:disable RedundantReturn

module Logstash
  def self.service_ip(node, instance = 'default', service = 'elasticsearch', interface = nil)
    if Chef::Config[:solo]
      service_ip = get_attribute_or_default(node, instance, "#{service}_ip")
    else
      results = []
      service_query = get_attribute_or_default(node, instance, "#{service}_query")
      Chef::Search::Query.new.search(:node, service_query) { |o| results << o }
      if !results.empty?
        service_ip = get_ip_for_node(results[0], interface)
      else
        service_ip = get_attribute_or_default(node, instance, "#{service}_ip")
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

  def self.get_attribute_or_default(node, instance_name, attribute_name)
    instance_attr = deep_fetch(node, 'logstash', 'instance', instance_name, attribute_name)
    default_attr = deep_fetch(node, 'logstash', 'instance_default', attribute_name)
    instance_attr || default_attr
  end

  private

  # Adapted from @sathvargo's chef-sugar project, as there's no way to install
  # a gem via libraries, and we didn't want to much up the recipes too much yet:
  # https://github.com/sethvargo/chef-sugar/blob/master/lib/chef/sugar/node.rb
  def self.deep_fetch(node, *keys)
    keys.map!(&:to_s)
    keys.reduce(node.attributes.to_hash) do |hash, key|
      hash[key]
    end
  rescue NoMethodError
    nil
  end
end
