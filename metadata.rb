# Encoding: utf-8
name             'logstash'
maintainer       'John E. Vincent'
maintainer_email 'lusis.org+github.com@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures logstash'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

version          '0.11.4'

%w(ubuntu debian redhat centos scientific amazon fedora).each do |os|
  supports os
end

%w(build-essential runit git ant java logrotate python ark curl).each do |ckbk|
  depends ckbk
end

%w(apt elasticsearch beaver).each do |ckbk|
  recommends ckbk
end
