# Encoding: utf-8
require 'spec_helper'

# Logstash Instance
# Centos won't detect it as a service, since it's using upstart
describe service('logstash_beaver'), if: %w(Debian Ubuntu).include?(os[:family]) do
  it { should be_enabled }
  it { should be_running }
end

describe user('logstash') do
  it { should exist }
end

# Logstash Config
describe file('/opt/logstash/beaver/etc/beaver.conf') do
  it { should be_file }
end

describe file('/opt/logstash/beaver/etc/conf.d') do
  it { should be_directory }
end
