require 'spec_helper'

describe 'logstash server' do
  it { pending 'it writes the tests for its code or else it gets the hose again' }
end

describe service('logstash_server') do
    it { should be_enabled }
    it { should be_running }
end
