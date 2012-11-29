include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "php::module_curl"
include_recipe "git"


if Chef::Config[:solo]
  es_server_ip = node['logstash']['elasticsearch_ip']
else
  es_server_results = search(:node, "roles:#{node['logstash']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}")
  unless es_server_results.empty?
    es_server_ip = es_server_results[0]['ipaddress']
  else
    es_server_ip = node['logstash']['elasticsearch_ip']
  end
end

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
