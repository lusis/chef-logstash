# Encoding: utf-8
default['logstash']['instance']['default']['index_cleaner']['days_to_keep'] = 31
default['logstash']['instance']['default']['index_cleaner']['cron'] = {
  'minute'   => '0',
  'hour'     => '*',
  'log_file' => '/dev/null'
}
