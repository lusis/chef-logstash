default['logstash']['basedir'] = '/opt/logstash'
default['logstash']['user'] = 'logstash'
default['logstash']['group'] = 'logstash'
default['logstash']['join_groups'] = []
default['logstash']['log_dir'] = '/var/log/logstash'
default['logstash']['pid_dir'] = '/var/run/logstash'
default['logstash']['create_account'] = true

# roles/flags for various search/discovery
default['logstash']['graphite_role'] = 'graphite_server'
default['logstash']['graphite_query'] = "roles:#{node['logstash']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['elasticsearch_query'] = "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['elasticsearch_cluster'] = 'logstash'
default['logstash']['elasticsearch_ip'] = ''
default['logstash']['elasticsearch_port'] = ''
default['logstash']['graphite_ip'] = ''

default['logstash']['patterns'] = {}
default['logstash']['install_zeromq'] = false

case node['platform_family']
when "rhel"
  default['logstash']['zeromq_packages'] = [ "zeromq",  "zeromq-devel"]
  if node['platform_version'].to_i >= 6
    default['logstash']['init_style'] = 'upstart'
  else
    default['logstash']['init_style'] = 'init'
  end
when "fedora"
  default['logstash']['zeromq_packages'] = [ "zeromq",  "zeromq-devel"]
  if node['platform_version'].to_i >= 9
    default['logstash']['init_style'] = 'upstart'
  else
    default['logstash']['init_style'] = 'init'
  end
when "debian"
  default['logstash']['zeromq_packages'] = [ "zeromq",  "libzmq-dev"]
  if node["platform"] == "ubuntu"
    if node['platform_version'].to_f >= 12.04
      default['logstash']['init_style'] = 'upstart-1.5'
    elsif node['platform_version'].to_f >= 9.04
      default['logstash']['init_style'] = 'upstart'
    else
      default['logstash']['init_style'] = 'runit'
    end
  else
    default['logstash']['init_style'] = 'runit'
  end
end
