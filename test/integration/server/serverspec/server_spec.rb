# Encoding: utf-8
require 'spec_helper'

# Java 1.6
describe command('java -version') do
  it { should return_stdout /java version "1.7.\d+_\d+"/ }
end

# Logstash Instance
describe service('logstash_server') do
  it { should be_enabled }
  it { should be_running }
end

describe user('logstash') do
  it { should exist }
end

# Logstash Config
describe file('/opt/logstash/server/etc/conf.d/input_syslog.conf') do
  it { should be_file }
end

describe file('/opt/logstash/server/etc/conf.d/output_elasticsearch.conf') do
  it { should be_file }
end

describe file('/opt/logstash/server/etc/conf.d/output_stdout.conf') do
  it { should be_file }
end

describe port(9200) do
  it { should be_listening }
end

describe port(5959) do
  it { should be_listening }
end

# Logstash Curator
describe cron do
  it { should have_entry('0 * * * * curator --host 127.0.0.1 -d 31 &> /dev/null').with_user('logstash') }
end
