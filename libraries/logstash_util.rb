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
    instance_attr = {} unless node['logstash']['instance'][instance_name]
    instance_attr = deep_fetch(node, 'logstash', 'instance', instance_name, attribute_name)
    default_attr = deep_fetch(node, 'logstash', 'instance_default', attribute_name)
    instance_attr || default_attr
  end

  def self.determine_native_init(node)
    platform_major_version = determine_platform_major_version(node)
    case node['platform']
    when 'ubuntu'
      if platform_major_version >= 6.10
        'upstart'
      else
        'sysvinit'
      end
    when 'debian'
      'sysvinit'
    when 'redhat', 'centos', 'scientific'
      if platform_major_version <= 6
        'sysvinit'
      else
        'systemd'
      end
    when 'amazon'
      if platform_major_version < 2011.02
        'sysvinit'
      else
        'upstart'
      end
    when 'fedora'
      if platform_major_version < 15
        'sysvinit'
      else
        'systemd'
      end
    else
      Chef::Log.fatal("We cannot determine your distribution's native init system")
    end
  end

  def self.upstart_supports_user?(node)
    platform_major_version = determine_platform_major_version(node)
    case node['platform']
    when 'ubuntu'
      if platform_major_version < 12.04
        false
      else
        true
      end
    when 'redhat', 'centos', 'scientific', 'amazon'
      false
    else
      Chef::Log.fatal("#{node['platform']} does not use upstart")
    end
  end

  def self.determine_platform_major_version(node)
    if node['platform'] == 'ubuntu' || node['platform'] == 'amazon'
      node['platform_version'].to_f
    else
      node['platform_version'].split('.').first.to_i
    end
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
