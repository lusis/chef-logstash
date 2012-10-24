include_recipe "python::pip"

python_pip "pyes" do
  action :install
end

directory "#{node['logstash']['basedir']}/index_cleaner" do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

cookbook_file "#{node['logstash']['basedir']}/index_cleaner/logstash_index_cleaner.py" do
  source "logstash_index_cleaner.py"
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0774"
end

# FIXME: http://tickets.opscode.com/browse/CHEF-3547
file "#{node['logstash']['basedir']}/index_cleaner/logstash_index_cleaner.py" do
  mode "0744"
  action :touch
  only_if { Chef::VERSION == "10.16.0" }
end

execute "index_cleaner" do
  cwd "#{node['logstash']['basedir']}/index_cleaner"
  command "./logstash_index_cleaner.py -d #{node['logstash']['index_cleaner']['days_to_keep']}"
end
