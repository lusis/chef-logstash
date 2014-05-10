# Encoding: utf-8
# Cookbook Name:: logstash
# Provider:: curator
# Author:: John E. Vincent
# License:: Apache 2.0
#
# Copyright 2014, John E. Vincent

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  @instance = new_resource.instance || 'default'
  if node['logstash']['instance'].key?(@instance)
    attributes = node['logstash']['instance'][@instance]
    defaults = node['logstash']['instance']['default']
  else
    attributes = node['logstash']['instance']['default']
  end
  @days_to_keep = new_resource.days_to_keep || attributes['curator_days_to_keep'] || defaults['curator_days_to_keep']
  @minute = new_resource.minute || attributes['curator_cron_minute'] || defaults['curator_cron_minute']
  @hour = new_resource.hour || attributes['curator_cron_hour'] || defaults['curator_cron_hour']
  @log_file = new_resource.log_file || attributes['curator_cron_log_file'] || defaults['curator_cron_log_file']
  @user = new_resource.user || attributes['user'] || defaults['user']
end


action :create do
  ls_instance = @instance
  ls_days_to_keep = @days_to_keep
  ls_log_file = @log_file
  ls_hour = @hour
  ls_minute = @minute
  ls_user = @user

  @run_context.include_recipe 'python::pip'

  pi = python_pip 'elasticsearch-curator' do
    action :install
  end
  new_resource.updated_by_last_action(pi.updated_by_last_action?)

  cr = cron 'logstash_index_cleaner' do
    command "curator --host #{::Logstash.service_ip(node, ls_instance, 'elasticsearch')} -d #{ls_days_to_keep} &> #{ls_log_file}"
    user    ls_user
    minute  ls_minute
    hour    ls_hour
  end
  new_resource.updated_by_last_action(cr.updated_by_last_action?)
end



