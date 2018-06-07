# Encoding: utf-8
name             'logstash'
maintainer       'John E. Vincent'
maintainer_email 'lusis.org+github.com@gmail.com'
license          'Apache-2.0'
description      'Installs/Configures logstash'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          '1.0.0'

%w(ubuntu debian redhat centos scientific amazon fedora).each do |os|
  supports os
end

depends 'build-essential'
depends 'runit'
depends 'git'
depends 'ant'
depends 'logrotate'
depends 'ark'
depends 'poise-python'
depends 'curl'
depends 'beaver'

chef_version '>= 12.19' if respond_to?(:chef_version)
issues_url       'https://github.com/lusis/chef-logstash/issues'
source_url       'https://github.com/lusis/chef-logstash'
