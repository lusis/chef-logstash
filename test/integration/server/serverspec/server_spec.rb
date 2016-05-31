# Encoding: utf-8
require_relative 'spec_helper'

# Java 1.8
describe command('java -version') do
  its(:stderr) { should match(/java version "1.8.\d+_\d+"/) }
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
describe file('/opt/logstash/server/etc/conf.d/input_syslog') do
  it { should be_file }
end

describe file('/opt/logstash/server/etc/conf.d/output_elasticsearch') do
  it { should be_file }
end

describe file('/opt/logstash/server/etc/conf.d/output_stdout') do
  it { should be_file }
end

describe file('/etc/logrotate.d/logstash_server') do
  it { should be_file }
  its(:content) { should match(/maxsize 25MB/) }
end

describe port(9200) do
  it { should be_listening }
end

describe port(5959) do
  it { should be_listening }
end

# Logstash Curator
describe cron do
  it { should have_entry('0 * * * * /usr/local/bin/curator --host 127.0.0.1 delete indices --older-than 31 --time-unit days --timestring \'\%Y.\%m.\%d\' --prefix logstash- &> /dev/null').with_user('logstash') }
end
