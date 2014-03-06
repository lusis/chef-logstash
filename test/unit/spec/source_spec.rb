# Encoding: utf-8
require_relative 'spec_helper'

describe 'logstash::source' do
  before { logstash_stubs }
  describe 'ubuntu' do
    let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

    it 'writes some chefspec code' do
      pending 'todo'
    end

  end
end
