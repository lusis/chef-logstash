# Encoding: utf-8
include_recipe 'java'

case node[:platform]
when "debian","ubuntu"
    include_recipe 'apt'
    apt_repository "logstash" do
        uri "http://packages.elasticsearch.org/logstash/1.3/debian"
        distribution "stable"
        components ["main"]
        key "http://packages.elasticsearch.org/GPG-KEY-elasticsearch"
        action :add
    end
when "centos","redhat","rhel"
    include_recipe 'yum'
    yum_repository "logstash" do
        description "logstash repository"
        baseurl "http://packages.elasticsearch.org/logstash/1.3/centos"
        gpgkey "http://packages.elasticsearch.org/GPG-KEY-elasticsearch"
        action :create

end





package 'logstash' do
    action :install
end
