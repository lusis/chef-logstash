include_recipe "git"
include_recipe "logrotate"

kibana_base = node['logstash']['kibana']['basedir']
kibana_home = node['logstash']['kibana']['home']
kibana_log_dir = node['logstash']['kibana']['log_dir']
kibana_pid_dir = node['logstash']['kibana']['pid_dir']

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby "1.9.3-p194" do
  global true
end

rbenv_gem "bundler" do
  ruby_version "1.9.3-p194"
end

if Chef::Config[:solo]
  es_server_ip = node['logstash']['elasticsearch_ip']
else
  es_server_results = search(:node, "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}")
  unless es_server_results.empty?
    es_server_ip = es_server_results[0]['ipaddress']
  else
    es_server_ip = node['logstash']['elasticsearch_ip'].empty? ? '127.0.0.1' : node['logstash']['elasticsearch_ip']
  end
end

es_server_port = node['logstash']['elasticsearch_port'].empty? ? '9200' : node['logstash']['elasticsearch_port']

#install new kibana version only if is true
case node['logstash']['kibana']['language'].downcase
when "ruby"

  user "kibana" do
    supports :manage_home => true
    home "/home/kibana"
    shell "/bin/bash"
  end
  
  node.set[:rbenv][:group_users] = [ "kibana" ]

  [ kibana_pid_dir, kibana_log_dir ].each do |dir|
    Chef::Log.debug(dir)
    directory dir do
      owner 'kibana'
      group 'kibana'
      recursive true
    end
  end

  Chef::Log.debug(kibana_base)
  directory kibana_base do
    owner 'kibana'
    group 'kibana'
    recursive true
  end
  
  # for some annoying reason Gemfile.lock is shipped w/ kibana
  file "gemfile_lock" do
    path  "#{node['logstash']['kibana']['basedir']}/#{node['logstash']['kibana']['sha']}/Gemfile.lock"
    action :nothing
  end
  
  git "#{node['logstash']['kibana']['basedir']}/#{node['logstash']['kibana']['sha']}" do
    repository node['logstash']['kibana']['repo']
    branch "kibana-ruby"
    action :sync
    user 'kibana'
    group 'kibana'
    notifies :delete, "file[gemfile_lock]", :immediately
  end

  link kibana_home do
    to "#{node['logstash']['kibana']['basedir']}/#{node['logstash']['kibana']['sha']}"
  end
  
  template '/home/kibana/.bash_profile' do # let bash handle our env vars
    source 'kibana-bash_profile.erb'
    owner 'kibana'
    group 'kibana'
    variables(
              :pid_dir => kibana_pid_dir,
              :log_dir => kibana_log_dir,
              :app_name => "kibana",
              :kibana_port => node['logstash']['kibana']['http_port'],
              :smart_index => node['logstash']['kibana']['smart_index_pattern'],
              :es_ip => es_server_ip,
              :es_port => es_server_port,
              :server_name => node['logstash']['kibana']['server_name']
              )
  end

  template "/etc/init.d/kibana" do
    source "kibana.init.erb"
    owner 'root'
    mode "755"
    variables(
              :kibana_home => kibana_home,
              :user => 'kibana'
              )
  end

  template "#{kibana_home}/KibanaConfig.rb" do
    source "kibana-config.rb.erb"
    owner 'kibana'
    mode 0755
  end
  
  template "#{kibana_home}/kibana-daemon.rb" do
    source "kibana-daemon.rb.erb"
    owner 'kibana'
    mode 0755
  end

  bash "bundle install" do
    cwd kibana_home
    code "source /etc/profile.d/rbenv.sh && bundle install"
    not_if { ::File.exists? "#{kibana_home}/Gemfile.lock" }
  end

  
  service "kibana" do
    supports :status => true, :restart => true
    action [:enable, :start]
    subscribes :restart, [ "link[#{kibana_home}]", "template[#{kibana_home}/KibanaConfig.rb]", "template[#{kibana_home}/kibana-daemon.rb]" ]
  end
    
  logrotate_app "kibana" do
    cookbook "logrotate"
    path "/var/log/kibana/kibana.output"
    frequency "daily"
    rotate 30
    create "644 kibana kibana"
  end
  
when "php"
  
  include_recipe "apache2"
  include_recipe "apache2::mod_php5"
  include_recipe "php::module_curl"

  kibana_version = node['logstash']['kibana']['sha']

  apache_module "php5" do
    action :enable
  end

  apache_site "default" do
    enable false
  end

  directory "#{node['logstash']['basedir']}/kibana/#{kibana_version}" do
    owner node['logstash']['user']
    group node['logstash']['group']
    recursive true
  end

  git "#{node['logstash']['basedir']}/kibana/#{kibana_version}" do
    repository node['logstash']['kibana']['repo']
    reference kibana_version
    action :sync
    user node['logstash']['user']
    group node['logstash']['group']
  end

  if platform? "redhat", "centos", "amazon", "fedora", "scientific"
    arch = node['kernel']['machine']    == "x86_64" ? "64" : ""
    file '/etc/httpd/mods-available/php5.load' do
      content "LoadModule php5_module /usr/lib#{arch}/httpd/modules/libphp5.so"
    end
  end

  link "#{node['logstash']['basedir']}/kibana/current" do
    to "#{node['logstash']['basedir']}/kibana/#{kibana_version}"
    notifies :restart, "service[apache2]"
  end

  template "#{node['apache']['dir']}/sites-available/kibana" do
    source node['logstash']['kibana']['apache_template']
    variables(:docroot => "#{node['logstash']['basedir']}/kibana/current",
              :server_name => node['logstash']['kibana']['server_name'])
  end

  apache_site "kibana"

  template "#{node['logstash']['basedir']}/kibana/current/config.php" do
    source node['logstash']['kibana']['config']
    owner node['logstash']['user']
    group node['logstash']['group']
    mode "0755"
    variables(:es_server_ip => es_server_ip)
  end

  if node['logstash']['kibana']['auth']['enabled']
    htpasswd_path     = "#{node['logstash']['basedir']}/kibana/#{kibana_version}/htpasswd"
    htpasswd_user     = node['logstash']['kibana']['auth']['user']
    htpasswd_password = node['logstash']['kibana']['auth']['password']

    file htpasswd_path do
      owner node['logstash']['user']
      group node['logstash']['group']
      mode "0755"
    end

    execute "add htpasswd file" do
      command "/usr/bin/htpasswd -b #{htpasswd_path} #{htpasswd_user} #{htpasswd_password}"
    end
  end
  service "apache2"

end
