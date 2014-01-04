#
# Cookbook Name:: logstash
# Recipe:: zero_mq_repo
#
#
include_recipe "java::default"
include_recipe "yum::default"

major_version = node['platform_version'].split('.').first.to_i

case
when platform_family?("rhel")
  yum_repository "zeromq" do
    description "zeromq repo"
    baseurl "http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/CentOS_CentOS-#{major_version}/"
    gpgkey "http://download.opensuse.org/repositories/home:/fengshuo:/zeromq/CentOS_CentOS-#{major_version}/repodata/repomd.xml.key"
    action :create
  end
when platform_family?("debian")
  apt_repository "zeromq-ppa" do
    uri "http://ppa.launchpad.net/chris-lea/zeromq/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "C7917B12"
    action :add
  end
  apt_repository "libpgm-ppa" do
    uri "http://ppa.launchpad.net/chris-lea/libpgm/ubuntu"
    distribution  node['lsb']['codename']
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "C7917B12"
    action :add
    notifies :run, "execute[apt-get update]", :immediately
  end
end