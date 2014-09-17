# Encoding: utf-8
# Cookbook Name:: logstash
# Provider:: plugins
# Author:: John E. Vincent
# License:: Apache 2.0
#
# Copyright 2014, John E. Vincent

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  @name = new_resource.name || 'contrib'
  @instance = new_resource.instance || 'default'

  @base_directory = new_resource.base_directory || Logstash.get_attribute_or_default(node, @instance, 'basedir')
  @version = new_resource.version || Logstash.get_attribute_or_default(node, @instance, 'plugins_version')
  @checksum = new_resource.checksum || Logstash.get_attribute_or_default(node, @instance, 'plugins_checksum')
  @source_url = new_resource.source_url || Logstash.get_attribute_or_default(node, @instance, 'plugins_source_url')
  @user = new_resource.user || Logstash.get_attribute_or_default(node, @instance, 'user')
  @group = new_resource.group || Logstash.get_attribute_or_default(node, @instance, 'group')
  @instance_dir = "#{@base_directory}/#{@instance}"
  @install_type = new_resource.install_type || Logstash.get_attribute_or_default(node, @instance, 'plugins_install_type')
  @install_check = new_resource.install_check || Logstash.get_attribute_or_default(node, @instance, 'plugins_check_if_installed')
end

action :create do
  ls_version = @version
  ls_checksum = @checksum
  ls_source_url = @source_url
  ls_basedir = @base_directory
  ls_user = @user
  ls_group = @group
  ls_name = @name
  ls_instance = @instance
  ls_instance_dir = @instance_dir
  ls_install_check = @install_check

  case @install_type
  when 'native'
    ex = execute "bin/plugin install #{ls_name}" do
      command "bin/plugin install #{ls_name}"
      user    ls_user
      group   ls_group
      cwd     ls_instance_dir
      notifies    :restart, "logstash_service[#{ls_instance}]"
      # this is a temp workaround to make the plugin command idempotent.
      not_if { ::File.exist?("#{ls_instance_dir}/#{ls_install_check}") }
    end
    new_resource.updated_by_last_action(ex.updated_by_last_action?)
  when 'tarball'
    @run_context.include_recipe 'ark::default'
    arkit = ark "#{ls_instance}_contrib" do
      name      ls_instance
      url       ls_source_url
      checksum  ls_checksum
      owner     ls_user
      group     ls_group
      mode      0755
      version   ls_version
      path      ls_basedir
      action    [:put]
      notifies    :restart, "logstash_service[#{ls_instance}]"
      # this is a temp workaround to ensure idempotent.
      not_if { ::File.exist?("#{ls_instance_dir}/#{ls_install_check}") }
    end
    new_resource.updated_by_last_action(arkit.updated_by_last_action?)
  else
    Chef::Application.fatal!("Unknown install type: #{@install_type}")
  end
end
