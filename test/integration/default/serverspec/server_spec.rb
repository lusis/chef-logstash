require 'spec_helper'

describe service('logstash-server') do
    it { should be_enabled }
    it { should be_running }
end