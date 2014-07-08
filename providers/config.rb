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
  if node['logstash']['instance'].key?(@instance)
    attributes = node['logstash']['instance'][@instance]
    defaults   = node['logstash']['instance']['default']
  else
    attributes = node['logstash']['instance']['default']
  end
  @basedir = attributes['basedir'] || defaults['basedir']
  @templates = new_resource.templates || attributes['config_templates'] || defaults['config_templates']
  @templates_cookbook = new_resource.templates_cookbook  || attributes['config_templates_cookbook'] || defaults['config_templates_cookbook']
  @variables = new_resource.variables || attributes['config_templates_variables'] || defaults['config_templates_variables']
  @owner     = new_resource.owner || attributes['user'] || defaults['user']
  @group     = new_resource.group || attributes['group'] || defaults['group']
  @mode      = new_resource.mode || '0644'
  @path      = new_resource.path || "#{@basedir}/#{@instance}/etc/conf.d"
  @service_name = new_resource.service_name || @instance
end

action :create do
  conf = conf_vars
  # Chef::Log.info("config vars: #{conf.inspect}")
  conf[:templates].each do |_template, file|
    tp = template "#{conf[:path]}/#{::File.basename(file).chomp(::File.extname(file))}" do
      source      file
      cookbook    conf[:templates_cookbook]
      owner       conf[:owner]
      group       conf[:group]
      mode        conf[:mode]
      variables   conf[:variables]
      notifies    :restart, "logstash_service[#{conf[:service_name]}]"
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
