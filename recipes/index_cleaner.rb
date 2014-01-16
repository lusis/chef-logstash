base_dir          = File.join(node['logstash']['basedir'], 'index_cleaner')
index_cleaner_bin = File.join(base_dir, 'index_cleaner.rb')
days_to_keep      = node['logstash']['index_cleaner']['days_to_keep']

directory base_dir do
  action :create
  mode "0755"
  owner node['logstash']['user']
  group node['logstash']['group']
end

cookbook_file index_cleaner_bin do
  source "index_cleaner.rb"
  owner node['logstash']['user']
  group node['logstash']['group']
  mode "0774"
end

# FIXME: http://tickets.opscode.com/browse/CHEF-3547
file index_cleaner_bin do
  mode "0744"
  action :touch
  only_if { Chef::VERSION == "10.16.0" }
end

cron "logstash_index_cleaner" do
  command "bash -l -c '#{index_cleaner_bin} #{days_to_keep} #{node['logstash']['index_cleaner']['es_host']}'"
  minute  node['logstash']['index_cleaner']['cron']['minute']
  hour    node['logstash']['index_cleaner']['cron']['hour']
end
