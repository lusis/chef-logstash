# Encoding: utf-8
#
# Cookbook Name:: logstash
# Recipe:: default
#

logstash_instance 'tarball' do
  version  '1.4.0.rc1'
  checksum 'b015fa130d589af957c9a48e6f59754f5c0954835abf44bd013547a6b6520e59'
  source_url 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.0.rc1.tar.gz'
  install_type 'tarball'
end
