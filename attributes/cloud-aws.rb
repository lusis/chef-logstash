default['logstash']['es-cloud-aws-plugin']['version'] = '1.14.0'
default['logstash']['es-cloud-aws-plugin']['download_url'] = "https://download.elasticsearch.org/elasticsearch/elasticsearch-cloud-aws/elasticsearch-cloud-aws-#{node['logstash']['es-cloud-aws-plugin']['version']}.zip"

default['logstash']['elasticsearch']['cloud']['aws']['access_key'] = nil
default['logstash']['elasticsearch']['cloud']['aws']['secret_key'] = nil
default['logstash']['elasticsearch']['cloud']['aws']['region'] = 'us-east'
default['logstash']['elasticsearch']['discovery']['ec2']['tag'] = {}
default['logstash']['elasticsearch']['discovery']['ec2']['groups'] = nil
default['logstash']['elasticsearch']['discovery']['ec2']['ping_timeout'] = '3s'
