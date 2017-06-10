# Encoding: utf-8
require_relative 'spec_helper'
require_relative 'server_spec'

::LWRP_PATTERN = {
  step_into: ['logstash_pattern']
}.merge(::UBUNTU_OPTS)

describe 'logstash::server' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(::LWRP_PATTERN) }
    let(:node) { runner.node }
    let(:chef_run) do
      runner.node.merge(::UBUNTU_OPTS)
      runner.node.set['memory']['total'] = '1024000kb'
      runner.node.set['logstash']['instance']['server']['pattern_templates'] = {
        'default' => 'patterns/custom_patterns.erb'
      }
      runner.node.set['logstash']['instance']['server']['pattern_templates_variables'] = {
        'test' => true
      }
      runner.node.set['logstash']['instance']['server']['basedir'] = '/opt/logstash'
      runner.node.set['logstash']['instance']['server']['user'] = 'logstash'
      runner.node.set['logstash']['instance']['server']['group'] = 'logstash'
      runner.node.set['logstash']['instance']['server']['pattern_templates_cookbook'] = 'logstash'
      runner.converge(described_recipe)
    end
    include_context 'stubs-common'

    it 'installs the pattern template' do
      expect(chef_run).to create_template('/opt/logstash/server/patterns/custom_patterns').with(
        source:   'patterns/custom_patterns.erb',
        cookbook: 'logstash',
        owner:     'logstash',
        group:    'logstash',
        mode:     '0644',
        variables: { 'test' => true },
        action: [:create]
      )
    end
  end
end
