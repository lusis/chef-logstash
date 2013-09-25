include_recipe 'ark'

# Put the EC2 discovery plugin in logstash home.
ark 'cloud-aws' do
  version           node['logstash']['es-cloud-aws-plugin']['version']
  url               node['logstash']['es-cloud-aws-plugin']['download_url']
  prefix_home       node['logstash']['server']['home']
  owner             node['logstash']['user']
  group             node['logstash']['group']
  strip_leading_dir false
  action            :install
end

# Create an ES conf file in the logstash working directory
template "#{node['logstash']['server']['home']}/elasticsearch.yml" do
  source    "logstash-elasticsearch.yml.erb"
  mode      0644
  owner     node['logstash']['user']
  group     node['logstash']['group']
  notifies  :restart, 'service[logstash_server]'
end

