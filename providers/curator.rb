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
  @days_to_keep = new_resource.days_to_keep || Logstash.get_attribute_or_default(node, @instance, 'curator_days_to_keep')
  @minute = new_resource.minute || Logstash.get_attribute_or_default(node, @instance, 'curator_cron_minute')
  @hour = new_resource.hour || Logstash.get_attribute_or_default(node, @instance, 'curator_cron_hour')
  @log_file = new_resource.log_file || Logstash.get_attribute_or_default(node, @instance, 'curator_cron_log_file')
  @user = new_resource.user || Logstash.get_attribute_or_default(node, @instance, 'user')
  @bin_dir = new_resource.bin_dir || Logstash.get_attribute_or_default(node, @instance, 'curator_bin_dir')
  @index_prefix = new_resource.index_prefix || Logstash.get_attribute_or_default(node, @instance, 'curator_index_prefix')
  @time_unit = new_resource.time_unit || Logstash.get_attribute_or_default(node, @instance, 'curator_time_unit')
  @timestring = new_resource.timestring || Logstash.get_attribute_or_default(node, @instance, 'curator_timestring')
end

action :create do
  cur_instance = @instance
  cur_days_to_keep = @days_to_keep
  cur_log_file = @log_file
  cur_hour = @hour
  cur_minute = @minute
  cur_user = @user
  cur_bin_dir = @bin_dir
  cur_index_prefix = @index_prefix
  cur_time_unit = @time_unit
  cur_timestring = @timestring

  pr = python_runtime '2' do
    action :install
  end
  new_resource.updated_by_last_action(pr.updated_by_last_action?)

  pp = python_package 'elasticsearch-curator' do
    action :install
  end
  new_resource.updated_by_last_action(pp.updated_by_last_action?)

  server_ip = ::Logstash.service_ip(node, cur_instance, 'elasticsearch')
  curator_args = "--host #{server_ip} delete indices --older-than #{cur_days_to_keep} --time-unit #{cur_time_unit} --timestring '#{cur_timestring}' --prefix #{cur_index_prefix} &> #{cur_log_file}"
  cr = cron "curator-#{cur_instance}" do
    command "#{cur_bin_dir}/curator #{curator_args}"
    user    cur_user
    minute  cur_minute
    hour    cur_hour
    action  [:create]
  end
  new_resource.updated_by_last_action(cr.updated_by_last_action?)
end

action :delete do
  cur_instance = @instance
  cur_days_to_keep = @days_to_keep
  cur_log_file = @log_file
  cur_hour = @hour
  cur_minute = @minute
  cur_user = @user
  cur_bin_dir = @bin_dir
  cur_index_prefix = @index_prefix

  pr = python_runtime '2' do
    action :install
  end
  new_resource.updated_by_last_action(pr.updated_by_last_action?)

  pp = python_package 'elasticsearch-curator' do
    action :uninstall
  end
  new_resource.updated_by_last_action(pp.updated_by_last_action?)

  host = ::Logstash.service_ip(node, cur_instance, 'elasticsearch')
  curator_args = "--host #{host} delete indices --older-than #{cur_days_to_keep} --time-unit #{cur_time_unit} --timestring '#{cur_timestring}' --prefix #{cur_index_prefix} 2>&1 > #{cur_log_file}"
  cr = cron "curator-#{cur_instance}" do
    command "#{cur_bin_dir}/curator #{curator_args}"
    user    cur_user
    minute  cur_minute
    hour    cur_hour
    action  [:delete]
  end
  new_resource.updated_by_last_action(cr.updated_by_last_action?)
end
