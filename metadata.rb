# Encoding: utf-8
name             'logstash'
maintainer       'John E. Vincent'
maintainer_email 'lusis.org+github.com@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures logstash'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          '0.12.1'

%w(ubuntu debian redhat centos scientific amazon fedora).each do |os|
  supports os
end

%w(build-essential runit git ant logrotate python ark curl).each do |ckbk|
  depends ckbk
end

depends 'java', '~> 1.50'

%w(elasticsearch beaver).each do |ckbk|
  recommends ckbk
end

chef_version '>= 12.7' if respond_to?(:chef_version)
