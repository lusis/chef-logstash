# Encoding: utf-8
#
# Cookbook Name:: logstash
# Recipe:: beaver
#
#
include_recipe 'logstash::default'
include_recipe 'python::default'
include_recipe 'logrotate'

package 'git'

defaults   = node['logstash']['instance']['default']
attributes = node['logstash']['beaver']

beaver_user  = attributes['user'] || defaults['user']
beaver_group = attributes['group'] || defaults['group']

basedir = "#{attributes['basedir'] || defaults['basedir']}/beaver"

conf_file = "#{basedir}/etc/beaver.conf"
confd_dir = "#{basedir}/etc/conf.d"
format = attributes['format']
log_file = attributes['log_file']
pid_file = "#{defaults['pid_dir']}/logstash_beaver.pid"

logstash_server_ip = nil
if Chef::Config[:solo]
  logstash_server_ip = attributes['server_ipaddress'] if attributes['server_ipaddress']
elsif attributes['server_ipaddress']
  logstash_server_ip = attributes['server_ipaddress']
elsif attributes['server_role']
  logstash_server_results = search(:node, "roles:#{attributes['server_role']}")
  logstash_server_ip = logstash_server_results[0]['ipaddress'] unless logstash_server_results.empty?
end

user_opts = attributes['user_opts'] || defaults['user_opts']
user beaver_user do
  home user_opts[:homedir]
  system true
  action :create
  manage_home true
  uid user_opts[:uid]
end

group beaver_group do
  gid user_opts[:gid]
  members beaver_user
  append true
  system true
end

# create some needed directories and files
directory basedir do
  owner beaver_user
  group beaver_group
  recursive true
end

[
  File.dirname(conf_file),
  File.dirname(log_file),
  File.dirname(pid_file),
  confd_dir
].each do |dir|
  directory dir do
    owner beaver_user
    group beaver_group
    recursive true
    not_if { ::File.exist?(dir) }
  end
end

[log_file, pid_file].each do |f|
  file f do
    action :touch
    owner beaver_user
    group beaver_group
    mode '0640'
  end
end

python_pip attributes['pika']['pip_package'] do
  action :install
end

python_pip attributes['pip_package'] do
  action :install
end

# inputs
files = []
attributes['inputs'].each do |ins|
  ins.each do |name, hash|
    case name
    when 'file' then
      if hash.key?('path')
        files << hash
      else
        log('input file has no path.') { level :warn }
      end
    else
      log("input type not supported: #{name}") { level :warn }
    end
  end
end

# outputs
outputs = []
conf = {}
attributes['outputs'].each do |outs|
  outs.each do |name, hash|
    case name
    when 'rabbitmq', 'amqp' then
      outputs << 'rabbitmq'
      conf['rabbitmq_host'] = hash['host'] || logstash_server_ip || 'localhost'
      conf['rabbitmq_port'] = hash['port'] if hash.key?('port')
      conf['rabbitmq_vhost'] = hash['vhost'] if hash.key?('vhost')
      conf['rabbitmq_username'] = hash['user'] if hash.key?('user')
      conf['rabbitmq_password'] = hash['password'] if hash.key?('password')
      conf['rabbitmq_queue'] = hash['queue'] if hash.key?('queue')
      conf['rabbitmq_exchange_type'] = hash['rabbitmq_exchange_type'] if hash.key?('rabbitmq_exchange_type')
      conf['rabbitmq_exchange'] = hash['exchange'] if hash.key?('exchange')
      conf['rabbitmq_exchange_durable'] = hash['durable'] if hash.key?('durable')
      conf['rabbitmq_key'] = hash['key'] if hash.key?('key')
    when 'redis' then
      outputs << 'redis'
      host = hash['host'] || logstash_server_ip || 'localhost'
      port = hash['port'] || '6379'
      db = hash['db'] || '0'
      conf['redis_url'] = "redis://#{host}:#{port}/#{db}"
      conf['redis_namespace'] = hash['key'] if hash.key?('key')
    when 'stdout' then
      outputs << 'stdout'
    when 'zmq', 'zeromq' then
      outputs << 'zmq'
      host = hash['host'] || logstash_server_ip || 'localhost'
      port = hash['port'] || '2120'
      conf['zeromq_address'] = "tcp://#{host}:#{port}"
    else
      log("output type not supported: #{name}") { level :warn }
    end
  end
end

conf['logstash_version'] = defaults['version'] >= '1.2' ? '1' : '0'

output = outputs[0]
log("multiple outpus detected, will consider only the first: #{output}") { level :warn } if outputs.length > 1
cmd = "beaver -t #{output} -c #{conf_file} -C #{confd_dir} -F #{format}"

template conf_file do
  source 'beaver.conf.erb'
  mode 0640
  owner beaver_user
  group beaver_group
  variables(
            conf: conf,
            files: files
  )
  notifies :restart, 'service[logstash_beaver]'
end

# use upstart when supported to get nice things like automatic respawns
use_upstart = false
supports_setuid = false
case node['platform_family']
when 'rhel'
  use_upstart = true if node['platform_version'].to_i >= 6
when 'fedora'
  use_upstart = true if node['platform_version'].to_i >= 9
when 'debian'
  use_upstart = true
  supports_setuid = true if node['platform_version'].to_f >= 12.04
end

if use_upstart
  template '/etc/init/logstash_beaver.conf' do
    mode '0644'
    source 'logstash_beaver.conf.erb'
    variables(
              cmd: cmd,
              group: defaults['supervisor_gid'],
              user: beaver_user,
              log: log_file,
              supports_setuid: supports_setuid,
              basedir: basedir
              )
    notifies :restart, 'service[logstash_beaver]'
  end

  service 'logstash_beaver' do
    supports restart: true, reload: false
    action [:enable, :start]
    provider Chef::Provider::Service::Upstart
  end
else
  template '/etc/init.d/logstash_beaver' do
    mode '0755'
    source 'init-beaver.erb'
    variables(
              cmd: cmd,
              pid_file: pid_file,
              user: beaver_user,
              log: log_file,
              platform: node['platform']
              )
    notifies :restart, 'service[logstash_beaver]'
  end

  service 'logstash_beaver' do
    supports restart: true, reload: false, status: true
    action [:enable, :start]
  end
end

logrotate_app 'logstash_beaver' do
  cookbook 'logrotate'
  path log_file
  frequency 'daily'
  postrotate attributes['logrotate']['postrotate']
  options attributes['logrotate']['options']
  rotate 30
  create "0640 #{beaver_user} #{beaver_group}"
end
