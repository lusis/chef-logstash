#
# Cookbook Name:: logstash
# Recipe:: beaver
#
#
include_recipe "logstash::default"
include_recipe "python::default"

git_package = 'git'

if platform?("ubuntu") 
  if node['platform_version'].to_f <= 11.04
    apt_repository "lucid-zeromq-ppa" do
      uri "http://ppa.launchpad.net/chris-lea/zeromq/ubuntu"
      distribution "lucid"
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "C7917B12"
      action :add
    end
    apt_repository "lucid-libpgm-ppa" do
      uri "http://ppa.launchpad.net/chris-lea/libpgm/ubuntu"
      distribution "lucid"
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "C7917B12"
      action :add
      notifies :run, "execute[apt-get update]", :immediately
    end
  end

  if node['platform_version'].to_f <= 10.04
    git_package = 'git-core'
  end
end

%w{argparse pika}.each do |pypkg|
  python_pip pypkg do
    action :install
  end
end

package git_package
package 'libzmq-dev'

basedir = node['logstash']['basedir'] + '/beaver'

conf_file = "#{basedir}/etc/beaver.conf"
log_file = "#{basedir}/log/logstash_beaver.log"
pid_file = "#{basedir}/run/logstash_beaver.pid"

logstash_server_ip = nil
if Chef::Config[:solo]
  logstash_server_ip = node['logstash']['beaver']['server_ipaddress'] if node['logstash']['beaver']['server_ipaddress']
elsif node['logstash']['beaver']['server_role']
  logstash_server_results = search(:node, "roles:#{node['logstash']['beaver']['server_role']}")
  unless logstash_server_results.empty?
    logstash_server_ip = logstash_server_results[0]['ipaddress']
  end
end


# create some needed directories and files
directory basedir do
  owner node['logstash']['user']
  group node['logstash']['group']
  recursive true
end
[
  File.dirname(conf_file),
  File.dirname(log_file),
  File.dirname(pid_file),
].each do |dir|
  directory dir do
    owner node['logstash']['user']
    group node['logstash']['group']
    recursive true
    not_if do ::File.exists?(dir) end
  end
end
[ log_file, pid_file ].each do |f|
  file f do
    action :touch
    owner node['logstash']['user']
    group node['logstash']['group']
    mode '0640'
  end
end

python_pip node['logstash']['beaver']['repo'] do
  action :install
end

# inputs
files = []
node['logstash']['beaver']['inputs'].each do |ins|
  ins.each do |name, hash|
    case name
      when "file" then
        if hash.has_key?('path')
          files << hash
        else
          log("input file has no path.") { level :warn }
        end
      else
        log("input type not supported: #{name}") { level :warn }
    end
  end
end

# outputs
outputs = []
config = []
node['logstash']['beaver']['outputs'].each do |outs|
  outs.each do |name, hash|
    case name
      when "rabbitmq", "amq" then
        outputs << "rabbitmq"
        host = hash['host'] || logstash_server_ip || 'localhost'
        config << "rabbitmq_host: #{host}"
        config << "rabbitmq_port: #{hash['port']}" if hash.has_key?('port')
        config << "rabbitmq_username: #{hash['user']}" if hash.has_key?('user')
        config << "rabbitmq_password: #{hash['pass']}" if hash.has_key?('pass')
        config << "rabbitmq_queue: #{hash['vhost']}" if hash.has_key?('vhost') # ??
        config << "rabbitmq_key: #{hash['key']}" if hash.has_key?('key')
        config << "rabbitmq_exchange: #{hash['name']}" if hash.has_key?('name')
        config << "rabbitmq_exchange_durable: #{hash['durable']}" if hash.has_key?('durable')
      when "redis" then
        outputs << "redis"
        host = hash['host'] || logstash_server_ip || 'localhost'
        port = hash['port'] || '6379'
        db = hash['db'] || '0'
        config << "redis_url: redis://#{host}:#{port}/#{db}"
        config << "redis_namespace: #{hash['key']}" if hash.has_key?('key')
      when "stdout" then
        outputs << "stdout"
      when "zmq", "zeromq" then
        outputs << "zmq"
        host = hash['host'] || logstash_server_ip || 'localhost'
        port = hash['port'] || '2120'
        config << "zeromq_address: tcp://#{host}:#{port}"
      else
        log("output type not supported: #{name}") { level :warn }
    end
  end
end

template conf_file do
  source 'beaver.conf.erb'
  mode 0640
  owner node['logstash']['user']
  group node['logstash']['group']
  variables(
    :files => files,
    :config => config.join("\n")
  )
  notifies :restart, "service[logstash_beaver]"
end

output = outputs[0]
if outputs.length > 1
  log("multiple outpus detected, will consider only the first: #{output}") { level :warn }
end

cmd = "beaver -t #{output} -c #{conf_file}"

if platform?("ubuntu") && node['platform_version'].to_f >= 10.04
  service "logstash_beaver" do
    supports :restart => true, :reload => false
    action [:enable, :start]
    provider Chef::Provider::Service::Upstart
  end
  template "/etc/init/logstash_beaver.conf" do
    mode "0755"
    source "upstart-beaver.erb"
    variables(
              :cmd => cmd,
              :pid_file => pid_file,
              :user => node['logstash']['user'],
              :log => log_file,
              :platform => node['platform']
              )
    notifies :restart, "service[logstash_beaver]"
  end
  file "/etc/init.d/logstash_beaver" do
    action :delete
    ignore_failure true
    only_if do
      File.exists?("/etc/init.d/logstash_beaver")
    end
  end
else
  service "logstash_beaver" do
    supports :restart => true, :reload => false, :status => true
    action [:enable, :start]
  end
  template "/etc/init.d/logstash_beaver" do
    mode "0755"
    source "init-beaver.erb"
    variables(
              :cmd => cmd,
              :pid_file => pid_file,
              :user => node['logstash']['user'],
              :log => log_file,
              :platform => node['platform']
              )
    notifies :restart, "service[logstash_beaver]"
  end
end

template '/etc/logrotate.d/logstash_beaver' do
  source 'logrotate-beaver.erb'
  owner 'root'
  group 'root'
  mode '0440'
  variables(
            :logfile => log_file,
            :user => node['logstash']['user'],
            :group => node['logstash']['group']
            )
end
