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

es_servers = find_nodes_by_groups('logsearch-elasticsearch')
# select an elasticsearch node based on the index of the logstash server
# so logseearch-logstash-2 -> logsearch-elasticsearch-2
# modulo the length of the elasticsearch servers to keep the index in range
es_host = es_servers[node["facet_index"] % es_servers.length].private_ip_address

cron "logstash_index_cleaner" do
  command "#{index_cleaner_bin} #{days_to_keep} #{es_host}"
  minute  node['logstash']['index_cleaner']['cron']['minute']
  hour    node['logstash']['index_cleaner']['cron']['hour']
end
