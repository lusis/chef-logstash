# Encoding: utf-8
require 'rspec/expectations'
require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'

require_relative 'support/matchers'

::LOG_LEVEL = :fatal

::REDHAT_OPTS = {
  platform:   'redhat',
  version:    '6.4',
  log_level:  ::LOG_LEVEL
}

::UBUNTU_OPTS = {
  platform:  'ubuntu',
  version:   '12.04',
  log_level: ::LOG_LEVEL
}

shared_context 'stubs-common' do
  before do
    Chef::Application.stub(:fatal!).and_return('fatal')
    stub_command("update-alternatives --display java | grep '/usr/lib/jvm/java-6-openjdk-amd64/jre/bin/java - priority 1061'").and_return(true)
    stub_command("/usr/bin/python -c 'import setuptools'").and_return(true)
    stub_command('test -f /opt/logstash/source/build/logstash-v1.3.2-monolithic.jar').and_return(true)
  end
end

shared_examples 'example' do
  #  it 'does not include example recipe by default' do
  #    expect(chef_run).not_to include_recipe('example::default')
  #  end
end

at_exit { ChefSpec::Coverage.report! }
