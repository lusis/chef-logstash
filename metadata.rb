maintainer       "John E. Vincent"
maintainer_email "lusis.org+github.com@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures logstash"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.3.2"

%w{apache2 php build-essential git runit python java ant rabbitmq}.each do |cb|
  depends cb
end
