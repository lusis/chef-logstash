# Encoding: utf-8

# roles/flags for various search/discovery
default['logstash']['instance']['default']['graphite_role'] = 'graphite_server'
default['logstash']['instance']['default']['graphite_query'] = "roles:#{node['logstash']['instance']['default']['graphite_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['instance']['default']['elasticsearch_role'] = 'elasticsearch_server'
default['logstash']['instance']['default']['elasticsearch_query'] = "roles:#{node['logstash']['instance']['default']['elasticsearch_role']} AND chef_environment:#{node.chef_environment}"
default['logstash']['instance']['default']['elasticsearch_cluster'] = 'logstash'
default['logstash']['instance']['default']['elasticsearch_ip'] = ''
default['logstash']['instance']['default']['elasticsearch_port'] = ''
default['logstash']['instance']['default']['graphite_ip'] = ''

# Default logstash instance variables
default['logstash']['instance']['default']['basedir'] = '/opt/logstash'
default['logstash']['instance']['default']['user'] = 'logstash'
default['logstash']['instance']['default']['group'] = 'logstash'
default['logstash']['instance']['default']['user_opts'] = { homedir: '/var/lib/logstash', uid: nil, gid: nil }
default['logstash']['instance']['default']['supervisor_gid'] = node['logstash']['instance']['default']['group']
default['logstash']['instance']['default']['pid_dir'] = '/var/run/logstash'
default['logstash']['instance']['default']['create_account'] = true
default['logstash']['instance']['default']['join_groups'] = []
default['logstash']['instance']['default']['homedir'] = '/var/lib/logstash'

default['logstash']['instance']['default']['version']        = '1.4.1'
default['logstash']['instance']['default']['source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-1.4.1.tar.gz'
default['logstash']['instance']['default']['checksum']       = 'a1db8eda3d8bf441430066c384578386601ae308ccabf5d723df33cee27304b4'
default['logstash']['instance']['default']['install_type']   = 'tarball'

default['logstash']['instance']['default']['plugins_version']        = '1.4.1'
default['logstash']['instance']['default']['plugins_source_url']     = 'https://download.elasticsearch.org/logstash/logstash/logstash-contrib-1.4.1.tar.gz'
default['logstash']['instance']['default']['plugins_checksum']       = 'beb0927351a3c298cd346225950c8d4fbda984ba54252d8a2f244329207c31e2'
default['logstash']['instance']['default']['plugins_install_type']   = 'tarball' # native|tarball
default['logstash']['instance']['default']['plugins_check_if_installed']  = 'lib/logstash/filters/translate.rb'

default['logstash']['instance']['default']['log_file']       = 'logstash.log'
default['logstash']['instance']['default']['xms']        = '1024M'
default['logstash']['instance']['default']['xmx']        = "#{(node['memory']['total'].to_i * 0.6).floor / 1024}M"
default['logstash']['instance']['default']['java_opts']  = ''
default['logstash']['instance']['default']['gc_opts']    = '-XX:+UseParallelOldGC'
default['logstash']['instance']['default']['ipv4_only']  = false
default['logstash']['instance']['default']['debug']      = false
default['logstash']['instance']['default']['workers']    = 1

default['logstash']['instance']['default']['pattern_templates_cookbook']  = 'logstash'
default['logstash']['instance']['default']['pattern_templates']           = {}
default['logstash']['instance']['default']['pattern_templates_variables'] = {}

default['logstash']['instance']['default']['base_config_cookbook']       = 'logstash'
default['logstash']['instance']['default']['base_config']    = '' # set if want data driven

default['logstash']['instance']['default']['config_file']                = ''
default['logstash']['instance']['default']['config_templates']           = {}
default['logstash']['instance']['default']['config_templates_cookbook']  = 'logstash'
default['logstash']['instance']['default']['config_templates_variables'] = {}

# allow control over the upstart config
default['logstash']['instance']['default']['upstart_with_sudo'] = false

default['logstash']['instance']['default']['init_method'] = 'native' # pleaserun or native or runit
default['logstash']['instance']['default']['service_templates_cookbook']  = 'logstash'

# roles/flags for various autoconfig/discovery components
default['logstash']['instance']['default']['enable_embedded_es'] = false
default['logstash']['instance']['default']['bind_host_interface'] = ''
default['logstash']['instance']['default']['es_index'] = nil

default['logstash']['instance']['default']['inputs'] = []
default['logstash']['instance']['default']['filters'] = []
default['logstash']['instance']['default']['outputs'] = []

default['logstash']['instance']['default']['web']['enable']  = false
default['logstash']['instance']['default']['web']['address'] = '0.0.0.0'
default['logstash']['instance']['default']['web']['port']    = '9292'

# Logging features
default['logstash']['instance']['default']['logrotate_enable']  = true
default['logstash']['instance']['default']['logrotate_options'] = %w(missingok notifempty compress copytruncate)
default['logstash']['instance']['default']['logrotate_frequency'] = 'daily'
default['logstash']['instance']['default']['logrotate_max_backup'] = 10
default['logstash']['instance']['default']['logrotate_max_size'] = '10M'
default['logstash']['instance']['default']['logrotate_use_filesize'] = false

# Curator
default['logstash']['instance']['default']['curator_days_to_keep'] = 31
default['logstash']['instance']['default']['curator_cron_minute'] = '0'
default['logstash']['instance']['default']['curator_cron_hour'] = '*'
default['logstash']['instance']['default']['curator_cron_log_file'] = '/dev/null'
