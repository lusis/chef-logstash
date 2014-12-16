# Encoding: utf-8
require_relative 'spec_helper'

describe 'logstash::pyshipper' do
  describe 'ubuntu' do
    let(:runner) { ChefSpec::SoloRunner.new(::UBUNTU_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      # runner.node.set['logstash'] ...
      runner.converge(described_recipe)
    end
    include_context 'stubs-common'

    it 'writes some chefspec code' do
      skip 'todo'
    end

  end
end
