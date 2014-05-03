# Encoding: utf-8
require_relative 'spec_helper'

describe 'logstash::index_cleaner' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::Runner.new(::UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      # runner.node.set['logstash'] ...
      runner.node.automatic['memory']['total'] = '1024kB'
      runner.converge(described_recipe)
    end
    include_context 'stubs-common'

    it 'installs elasticsearch_curator' do
      expect(chef_run).to install_python_pip('elasticsearch-curator')
    end

    it 'creates a cronjob' do
      expect(chef_run).to create_cron('logstash_index_cleaner')
    end

  end
end
