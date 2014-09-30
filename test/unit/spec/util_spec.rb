require_relative '../../../libraries/logstash_util.rb'

describe '::determine_platform_major_version' do
  context 'with ubuntu' do
    let(:node) { { 'platform' => 'ubuntu', 'platform_version' => '12.04' } }
    it 'returns full version' do
      expect(Logstash.determine_platform_major_version(node)).to eql(12.04)
    end
  end

  context 'with amazon' do
    let(:node) { { 'platform' => 'amazon', 'platform_version' => '2014.03' } }
    it 'returns full version' do
      expect(Logstash.determine_platform_major_version(node)).to eql(2014.03)
    end
  end

  context 'with other distributions' do
    let(:node) { { 'platform' => 'debian', 'platform_version' => '7.6' } }
    it 'returns version without point release' do
      expect(Logstash.determine_platform_major_version(node)).to eql(7)
    end
  end
end

describe '::determine_native_init' do
  context 'with ubuntu' do
    context 'before upstart' do
      let(:node) { { 'platform' => 'ubuntu', 'platform_version' => '6.04' } }
      it 'returns sysvinit' do
        expect(Logstash.determine_native_init(node)).to eql('sysvinit')
      end
    end
    context 'after upstart' do
      let(:node) { { 'platform' => 'ubuntu', 'platform_version' => '6.10' } }
      it 'returns upstart' do
        expect(Logstash.determine_native_init(node)).to eql('upstart')
      end
    end
  end

  context 'with debian' do
    let(:node) { { 'platform' => 'debian', 'platform_version' => '7.6' } }
    it 'returns sysvinit' do
      expect(Logstash.determine_native_init(node)).to eql('sysvinit')
    end
  end

  context 'with el' do
    context 'with 5' do
      let(:node) { { 'platform' => 'centos', 'platform_version' => '5' } }
      it 'returns sysvinit' do
        expect(Logstash.determine_native_init(node)).to eql('sysvinit')
      end
    end
    context 'with 6' do
      let(:node) { { 'platform' => 'centos', 'platform_version' => '6' } }
      it 'returns upstart' do
        expect(Logstash.determine_native_init(node)).to eql('upstart')
      end
    end
    context 'with 7' do
      let(:node) { { 'platform' => 'centos', 'platform_version' => '7' } }
      it 'returns systemd' do
        expect(Logstash.determine_native_init(node)).to eql('systemd')
      end
    end
  end

  context 'with amazon' do
    context 'before upstart' do
      let(:node) { { 'platform' => 'amazon', 'platform_version' => '2010.11' } }
      it 'returns sysvinit' do
        expect(Logstash.determine_native_init(node)).to eql('sysvinit')
      end
    end
    context 'after upstart' do
      let(:node) { { 'platform' => 'amazon', 'platform_version' => '2011.02' } }
      it 'returns upstart' do
        expect(Logstash.determine_native_init(node)).to eql('upstart')
      end
    end
  end

  context 'with fedora' do
    context 'before systemd' do
      let(:node) { { 'platform' => 'fedora', 'platform_version' => '14' } }
      it 'returns sysvinit' do
        expect(Logstash.determine_native_init(node)).to eql('sysvinit')
      end
    end
    context 'after systemd' do
      let(:node) { { 'platform' => 'fedora', 'platform_version' => '15' } }
      it 'returns systemd' do
        expect(Logstash.determine_native_init(node)).to eql('systemd')
      end
    end
  end

end
