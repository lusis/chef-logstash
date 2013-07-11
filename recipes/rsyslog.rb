require 'digest/md5'

node['logstash']['rsyslog']['packages'].each do |pkg|
  package pkg
end

template "#{node['logstash']['rsyslog']['config_file']}" do
  source node['logstash']['rsyslog']['base_config']
  cookbook node['logstash']['rsyslog']['base_config_cookbook']
  owner "root"
  group "root"
  mode "0644"
  only_if { node['logstash']['rsyslog']['write_config'] }
end

directory "#{node['logstash']['rsyslog']['config_dir']}" do
  owner node['logstash']['user']
  owner "root"
  group "root"
  mode "0755"
end

config_sections = [*node['logstash']['rsyslog']['config_sections']]

unless (watched_logs = [*node['logstash']['rsyslog']['watched_logs']]).empty?
  watched_log_section = {
    'filename' => '50-watched-logs.conf',
    'watches' => []
  }

  watched_logs.map{ |l| Dir.glob(l) }.flatten.each do |watched_log|
    namebase = File.basename(watched_log, File.extname(watched_log))
    dashname = File.join(
      File.dirname(watched_log), namebase
    ).sub(%r{^/}, '').gsub(%r{[^a-z0-9]}i, '-')

    watched_log_section['watches'] << {
      'name' => watched_log,
      'tag' => "#{dashname}:",
      'state_file' => "state-#{dashname}",
    }
  end

  config_sections << watched_log_section
end

if node['logstash']['rsyslog']['ship_everything'] && node['logstash']['rsyslog']['tcp_server']
  config_sections << {
    'filename' => '99-logstash.conf',
    'directives' => {
      '*.*' => "@@#{node['logstash']['rsyslog']['tcp_server']}"
    }
  }
end

config_sections.each do |config_section|
  template "#{node['logstash']['rsyslog']['config_dir']}/#{config_section['filename']}" do
    source node['logstash']['rsyslog']['base_config_section']
    cookbook node['logstash']['rsyslog']['base_config_section_cookbook']
    variables(:cfg => config_section)
    owner "root"
    group "root"
    mode "0644"
  end
end
