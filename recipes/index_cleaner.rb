# Encoding: utf-8
include_recipe 'python::pip'

days_to_keep      = node['logstash']['index_cleaner']['days_to_keep']
log_file          = node['logstash']['index_cleaner']['cron']['log_file']

python_pip 'elasticsearch-curator' do
  action :install
end

cron 'logstash_index_cleaner' do
  command "curator --host #{::Logstash.es_server_ip(node)} -d #{days_to_keep} &> #{log_file}"
  minute  node['logstash']['index_cleaner']['cron']['minute']
  hour    node['logstash']['index_cleaner']['cron']['hour']
end
