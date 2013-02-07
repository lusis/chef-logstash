name             "logstash"
maintainer       "John E. Vincent"
maintainer_email "lusis.org+github.com@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures logstash"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.5.4"

supports         "ubuntu"
supports         "debian"

supports         "redhat"
supports         "centos"
supports         "scientific"
supports         "amazon"
supports         "fedora"

%w{ apache2 php build-essential git rvm runit python java ant logrotate rabbitmq }.each do |ckbk|
  depends ckbk
end
