# Encoding: utf-8
# Cookbook Name:: logstash
# Provider:: config
# Author:: John E. Vincent
# License:: Apache 2.0
#
# Copyright 2014, John E. Vincent

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  @instance  = new_resource.instance
  @basedir = Logstash.get_attribute_or_default(node, @instance, 'basedir')
  @templates = new_resource.templates || Logstash.get_attribute_or_default(node, @instance, 'config_templates')
  @templates_cookbook = new_resource.templates_cookbook || Logstash.get_attribute_or_default(node, @instance, 'config_templates_cookbook')

  # merge user overrides into defaults for configuration variables
  attributes = Logstash.get_attribute_or_default(node, @instance, 'config_templates_variables')
  defaults = node['logstash']['instance_default']['config_templates_variables']
  @variables = ({}).merge(new_resource.variables || {}).merge(defaults || {}).merge(attributes || {})

  @owner     = new_resource.owner || Logstash.get_attribute_or_default(node, @instance, 'user')
  @group     = new_resource.group || Logstash.get_attribute_or_default(node, @instance, 'group')
  @mode      = new_resource.mode || '0644'
  @path      = new_resource.path || "#{@basedir}/#{@instance}/etc/conf.d"
  @service_name = new_resource.service_name || @instance
end

use_inline_resources

action :create do
  conf = conf_vars
  # Chef::Log.info("config vars: #{conf.inspect}")
  conf[:templates].each do |template, file|
    tp = template "#{conf[:path]}/#{::File.basename(template).chomp(::File.extname(template))}" do
      source      file
      cookbook    conf[:templates_cookbook]
      owner       conf[:owner]
      group       conf[:group]
      mode        conf[:mode]
      variables   conf[:variables]
      action      :create
    end
    new_resource.updated_by_last_action(tp.updated_by_last_action?)
  end
end

private

def conf_vars
  conf = {
    instance:   @instance,
    templates:  @templates,
    variables:  @variables,
    path:       @path,
    owner:      @owner,
    group:      @group,
    mode:       @mode,
    service_name: @service_name,
    templates_cookbook:   @templates_cookbook
  }
  conf
end
