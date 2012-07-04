include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "php::module_curl"

es_server = search(:node, "roles:#{node[:logstash][:kibana][:elasticsearch_role]} AND chef_environment:#{node.chef_environment}")
kibana_version = node[:logstash][:kibana][:sha]

apache_module "php5" do
  action :enable
end

apache_site "default" do
  action :disable
end

directory "#{node[:logstash][:basedir]}/kibana" do
  user "#{node[:logstash][:user]}"
  group "#{node[:logstash][:group]}"
end

git "#{node[:logstash][:basedir]}/kibana/#{kibana_version}" do
  repository "#{node[:logstash][:kibana][:repo]}"
  reference "#{kibana_version}"
  action :sync
  user "#{node[:logstash][:user]}"
  group "#{node[:logstash][:group]}"
end

link "#{node[:logstash][:basedir]}/kibana/current" do
  to "#{node[:logstash][:basedir]}/kibana/#{kibana_version}"
  notifies :restart, "service[apache2]"
end

template "#{node['apache']['dir']}/sites-available/kibana" do
  source "#{node[:logstash][:kibana][:apache_template]}"
  variables(:docroot => "#{node[:logstash][:basedir]}/kibana/current",
            :server_name => "#{node[:logstash][:kibana][:server_name]}")
end

apache_site "kibana" 

template "#{node[:logstash][:basedir]}/kibana/current/config.php" do
  source "#{node[:logstash][:kibana][:config]}"
  user "#{node[:logstash][:user]}"
  group "#{node[:logstash][:group]}"
  mode "0755"
  variables(@es_server => es_server)
end

service "apache2"
