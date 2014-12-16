# Encoding: utf-8

# roles/flags for various search/discovery
default['logstash']['instance_default']['graphite_role'] = 'graphite_server'
default['logstash']['instance_default']['graphite_query'] = "roles:#{node['logstash']['instance_default']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['instance_default']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['instance_default']['elasticsearch_query'] = "roles:#{node['logstash']['instance_default']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['instance_default']['elasticsearch_cluster'] = 'logstash'
default['logstash']['instance_default']['elasticsearch_ip'] = ''
default['logstash']['instance_default']['elasticsearch_port'] = ''
default['logstash']['instance_default']['elasticsearch_embedded'] = true
default['logstash']['instance_default']['graphite_ip'] = ''

# Default logstash instance variables
default['logstash']['instance_default']['basedir'] = '/opt/logstash'
default['logstash']['instance_default']['user'] = 'logstash'
default['logstash']['instance_default']['group'] = 'logstash'
default['logstash']['instance_default']['user_opts'] = { homedir: '/var/lib/logstash', uid: nil, gid: nil }
default['logstash']['instance_default']['supervisor_gid'] = node['logstash']['instance_default']['group']
default['logstash']['instance_default']['pid_dir'] = '/var/run/logstash'
default['logstash']['instance_default']['create_account'] = true
default['logstash']['instance_default']['join_groups'] = []
default['logstash']['instance_default']['homedir'] = '/var/lib/logstash'

default['logstash']['instance_default']['version']        = '1.4.2'
default['logstash']['instance_default']['source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz'
default['logstash']['instance_default']['checksum']       = 'd5be171af8d4ca966a0c731fc34f5deeee9d7631319e3660d1df99e43c5f8069'
default['logstash']['instance_default']['install_type']   = 'tarball'

default['logstash']['instance_default']['plugins_version']        = '1.4.2'
default['logstash']['instance_default']['plugins_source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-contrib-1.4.2.tar.gz'
default['logstash']['instance_default']['plugins_checksum']       = '7497ca3614ba9122159692cc6e60ffc968219047e88de97ecc47c2bf117ba4e5'
default['logstash']['instance_default']['plugins_install_type']   = 'tarball' # native|tarball
default['logstash']['instance_default']['plugins_check_if_installed']  = 'lib/logstash/filters/translate.rb'

default['logstash']['instance_default']['log_file']   = 'logstash.log'
default['logstash']['instance_default']['java_home']  = '/usr/lib/jvm/java-6-openjdk' # openjdk6 on ubuntu
default['logstash']['instance_default']['xms']        = "#{(node['memory']['total'].to_i * 0.2).floor / 1024}M"
default['logstash']['instance_default']['xmx']        = "#{(node['memory']['total'].to_i * 0.6).floor / 1024}M"
default['logstash']['instance_default']['java_opts']  = ''
default['logstash']['instance_default']['gc_opts']    = '-XX:+UseParallelOldGC'
default['logstash']['instance_default']['ipv4_only']  = false
default['logstash']['instance_default']['debug']      = false
default['logstash']['instance_default']['workers']    = 1

default['logstash']['instance_default']['pattern_templates_cookbook']  = 'logstash'
default['logstash']['instance_default']['pattern_templates']           = {}
default['logstash']['instance_default']['pattern_templates_variables'] = {}

default['logstash']['instance_default']['base_config_cookbook']       = 'logstash'
default['logstash']['instance_default']['base_config']    = '' # set if want data driven

default['logstash']['instance_default']['config_file']                = ''
default['logstash']['instance_default']['config_templates']           = {}
default['logstash']['instance_default']['config_templates_cookbook']  = 'logstash'
default['logstash']['instance_default']['config_templates_variables'] = {}

default['logstash']['instance_default']['init_method'] = 'runit'
default['logstash']['instance_default']['service_templates_cookbook']  = 'logstash'

# default locations for runit templates
default['logstash']['instance_default']['runit_run_template_name'] = 'logstash'
default['logstash']['instance_default']['runit_log_template_name'] = 'logstash'

default['logstash']['instance_default']['limit_nofile_soft']  = 65550
default['logstash']['instance_default']['limit_nofile_hard']  = 65550

# roles/flags for various autoconfig/discovery components
default['logstash']['instance_default']['enable_embedded_es'] = false
default['logstash']['instance_default']['bind_host_interface'] = ''
default['logstash']['instance_default']['es_index'] = nil

default['logstash']['instance_default']['inputs'] = []
default['logstash']['instance_default']['filters'] = []
default['logstash']['instance_default']['outputs'] = []

default['logstash']['instance_default']['web']['enable']  = false
default['logstash']['instance_default']['web']['address'] = '0.0.0.0'
default['logstash']['instance_default']['web']['port']    = '9292'

# Logging features
default['logstash']['instance_default']['logrotate_enable']  = true
default['logstash']['instance_default']['logrotate_options'] = %w(missingok notifempty compress copytruncate)
default['logstash']['instance_default']['logrotate_frequency'] = 'daily'
default['logstash']['instance_default']['logrotate_max_backup'] = 10
default['logstash']['instance_default']['logrotate_max_size'] = '10M'
default['logstash']['instance_default']['logrotate_use_filesize'] = false

# Curator
default['logstash']['instance_default']['curator_bin_dir'] = '/usr/local/bin'
default['logstash']['instance_default']['curator_days_to_keep'] = 31
default['logstash']['instance_default']['curator_cron_minute'] = '0'
default['logstash']['instance_default']['curator_cron_hour'] = '*'
default['logstash']['instance_default']['curator_cron_log_file'] = '/dev/null'

# Make sure instance key exists
default['logstash']['instance']
