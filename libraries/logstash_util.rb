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
      if platform_major_version <= 5
        'sysvinit'
      elsif platform_major_version == 6
        'upstart'
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
end
