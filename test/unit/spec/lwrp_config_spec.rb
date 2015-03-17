# Encoding: utf-8
require_relative 'spec_helper'
require_relative 'server_spec'

::LWRP = {
  step_into: ['logstash_config']
}.merge(::UBUNTU_OPTS)

describe 'logstash::server' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(::LWRP) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.node.set['memory']['total'] = '1024000kb'
      runner.node.set['logstash']['instance']['server']['basedir'] = '/opt/logstash'
      runner.node.set['logstash']['instance']['server']['user'] = 'logstash'
      runner.node.set['logstash']['instance']['server']['group'] = 'logstash'
      runner.node.set['logstash']['instance']['server']['config_templates_cookbook'] = 'logstash'
      runner.node.set['logstash']['instance']['server']['elasticsearch_ip'] = '127.0.0.1'
      runner.node.set['logstash']['instance']['server']['enable_embedded_es'] = true
      runner.node.set['logstash']['instance']['server']['config_templates'] = {
        output_stdout: 'config/output_stdout.conf.erb'
      }
      runner.converge(described_recipe)
    end
    include_context 'stubs-common'

    it 'installs the output_stdout template' do
      expect(chef_run).to create_template('/opt/logstash/server/etc/conf.d/output_stdout').with(
        source:   'config/output_stdout.conf.erb',
        cookbook: 'logstash',
        owner:     'logstash',
        group:    'logstash',
        mode:     '0644',
        action: [:create]
      )
    end
  end
end
