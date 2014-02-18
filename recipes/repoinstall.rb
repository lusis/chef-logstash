# Encoding: utf-8
include_recipe 'java'


case node[:platform]
when "debian","ubuntu"
    include_recipe 'apt'
    apt_repository "logstash" do
        uri node['logstash']['repo']['apt']['url']
        distribution node['logstash']['repo']['apt']['distro']
        components node['logstash']['repo']['apt']['components']
        key node['logstash']['repo']['apt']['gpgkey']
        action :add
    end
when "centos","redhat","rhel"
    include_recipe 'yum'
    yum_repository "logstash" do
        description node['logstash']['repo']['yum']['description']
        baseurl node['logstash']['repo']['yum']['url']
        gpgkey node['logstash']['repo']['yum']['gpgkey']
        action :create
    end
end

package 'logstash' do
    action :install
end
