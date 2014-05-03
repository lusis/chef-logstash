# Encoding: utf-8

# TURN This into a LWRP please!!!!!!

include_recipe 'python::pip'

days_to_keep = node['logstash']['instance']['default']['index_cleaner']['days_to_keep']
log_file     = node['logstash']['instance']['default']['index_cleaner']['cron']['log_file']

python_pip 'elasticsearch-curator' do
  action :install
end

cron 'logstash_index_cleaner' do
  command "curator --host #{::Logstash.service_ip(node)} -d #{days_to_keep} &> #{log_file}"
  minute  node['logstash']['instance']['default']['index_cleaner']['cron']['minute']
  hour    node['logstash']['instance']['default']['index_cleaner']['cron']['hour']
end
