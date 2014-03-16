# Encoding: utf-8
# Cookbook Name:: logstash
# Provider:: service
# Author:: John E. Vincent
# License:: Apache 2.0
#
# Copyright 2014, John E. Vincent

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  @instance = new_resource.instance
  @service_name = new_resource.service_name || "logstash_#{@instance}"
  @home = "#{node['logstash']['instance'][@instance]['basedir']}/#{@instance}"
  @method = new_resource.method
  @command = new_resource.command || "#{@home}/bin/logstash"
  @args = new_resource.args || default_args
  @description = new_resource.description || @service_name
  @chdir = new_resource.chdir || @home
  @user = new_resource.user || node['logstash']['instance'][@instance]['user']
  @group = new_resource.group || node['logstash']['instance'][@instance]['group']
end

action :create do
  @run_context.include_recipe 'pleaserun::default'
  svc_name = @instance
  svc_service_name = @service_name
  svc_home = @home
  svc_method = @method
  svc_command = @command
  svc_args = @args
  svc_description = @description
  svc_chdir = @chdir
  svc_user = @user
  svc_group = @group
  pr = pleaserun svc_service_name do
    name        svc_service_name
    program     svc_command
    args        svc_args
    description svc_description
    chdir       svc_chdir
    user        svc_user
    group       svc_group
    action      :create
    not_if { ::File.exists?("/etc/init.d/#{svc_service_name}") }
  end
  new_resource.updated_by_last_action(pr.updated_by_last_action?)
end

private

def default_args
  logstash_home = "#{node['logstash']['instance'][@instance]['basedir']}/#{@instance}"
  args      = ['agent', '-f', "#{node['logstash']['instance'][@instance]['home']}/etc/conf.d/"]
  args.concat ['--pluginpath', node['logstash']['instance'][@instance]['pluginpath']] if node['logstash']['instance'][@instance]['pluginpath']
  args.concat ['-vv'] if node['logstash']['instance'][@instance]['debug']
  args.concat ['-l', "#{logstash_home}/log/#{node['logstash']['instance'][@instance]['log_file']}"] if node['logstash']['instance'][@instance]['log_file']
  args.concat ['-w', node['logstash']['instance'][@instance]['workers'].to_s] if node['logstash']['instance'][@instance]['workers']
  args
end
