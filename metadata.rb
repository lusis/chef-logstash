name             "logstash"
maintainer       "John E. Vincent"
maintainer_email "lusis.org+github.com@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures logstash"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.5.1"

supports         "ubuntu"
supports         "debian"

supports         "redhat"
supports         "centos"
supports         "scientific"
supports         "amazon"
supports         "fedora"

depends "apache2"
depends "php"
depends "build-essential"
depends "git"
depends "runit"
depends "python"
depends "java"
depends "ant"
depends "logrotate"
depends "rabbitmq"
