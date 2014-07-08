# Encoding: utf-8
require_relative 'spec_helper'

describe 'logstash::agent' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(::UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      # runner.node.set['logstash'] ...
      runner.node.automatic['memory']['total'] = '1024kB'
      runner.node.set['logstash']['instance']['agent']['basedir'] = '/opt/logstash'
      runner.node.set['logstash']['instance']['agent']['user'] = 'logstash'
      runner.node.set['logstash']['instance']['agent']['group'] = 'logstash'
      runner.node.set['logstash']['instance']['agent']['config_templates_cookbook'] = 'logstash'
      runner.node.set['logstash']['instance']['agent']['elasticsearch_ip'] = '127.0.0.1'
      runner.node.set['logstash']['instance']['agent']['enable_embedded_es'] = false
      runner.converge(described_recipe)
    end
    include_context 'stubs-common'

    it 'calls the logstash_instance LWRP' do
      expect(chef_run).to create_logstash_instance('agent')
    end

    it 'calls the logstash_config LWRP' do
      expect(chef_run).to create_logstash_config('agent')
    end

    it 'calls the logstash_pattern LWRP' do
      expect(chef_run).to create_logstash_pattern('agent')
    end

    it 'calls the logstash_instance LWRP' do
      expect(chef_run).to enable_logstash_service('agent')
      expect(chef_run).to start_logstash_service('agent')
    end

  end
end
