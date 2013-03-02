default['logstash']['es-cloud-aws-plugin']['version'] = '1.11.0'
default['logstash']['es-cloud-aws-plugin']['download_url'] = "https://download.elasticsearch.org/elasticsearch/elasticsearch-cloud-aws/elasticsearch-cloud-aws-#{node['logstash']['es-cloud-aws-plugin']['version']}.zip"

default['logstash']['elasticsearch']['cluster_name'] = 'logstash'
default['logstash']['elasticsearch']['cloud']['aws']['access_key'] = ''
default['logstash']['elasticsearch']['cloud']['aws']['secret_key'] = ''
default['logstash']['elasticsearch']['cloud']['aws']['region'] = 'us-east'
default['logstash']['elasticsearch']['discovery']['ec2']['groups'] = 'default'
default['logstash']['elasticsearch']['discovery']['ec2']['ping_timeout'] = '3s'