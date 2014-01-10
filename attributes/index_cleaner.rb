default['logstash']['index_cleaner']['days_to_keep'] = 7
default['logstash']['index_cleaner']['cron'] = {
  'minute'   => '0',
  'hour'     => '*',
  'log_file' => '/dev/null'
}
default['logstash']['index_cleaner']['es_host'] = 'localhost'
