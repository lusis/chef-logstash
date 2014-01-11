# Encoding: utf-8
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'

::LOG_LEVEL = :fatal

::UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '12.04',
  log_level: ::LOG_LEVEL
}

def logstash_stubs
  stub_command("update-alternatives --display java | grep '/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java - priority 1061'").and_return(true)
  stub_command("/usr/bin/python -c 'import setuptools'").and_return(true)
  stub_command('test -f /opt/logstash/source/build/logstash-v1.3.2-monolithic.jar').and_return(true)
end
