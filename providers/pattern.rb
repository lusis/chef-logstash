# Encoding: utf-8
# Cookbook Name:: logstash
# Provider:: patterns
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
    defaults = node['logstash']['instance']['default']
  else
    attributes = node['logstash']['instance']['default']
  end
  @basedir = attributes['basedir'] || defaults['basedir']
  @templates = new_resource.templates || attributes['pattern_templates'] || defaults['pattern_templates']
  @variables = new_resource.variables || attributes['pattern_templates_variables'] || defaults['pattern_templates_variables']
  @owner     = new_resource.owner || attributes['user'] || defaults['user']
  @group     = new_resource.group || attributes['group'] || defaults['group']
  @templates_cookbook = new_resource.templates_cookbook || attributes['pattern_templates_cookbook'] || defaults['pattern_templates_cookbook']
  @mode      = new_resource.mode || '0644'
  @path      = new_resource.path || "#{@basedir}/#{@instance}/patterns"
end

action :create do
  pattern = pattern_vars
  # Chef::Log.info("config vars: #{pattern.inspect}")
  pattern[:templates].each do |_template, file|
    tp = template "#{pattern[:path]}/#{::File.basename(file).chomp(::File.extname(file))}" do
      source      file
      cookbook    pattern[:templates_cookbook]
      owner       pattern[:owner]
      group       pattern[:group]
      mode        pattern[:mode]
      variables   pattern[:variables]
      notifies    :restart, "logstash_service[#{pattern[:instance]}]"
      action      :create
    end
    new_resource.updated_by_last_action(tp.updated_by_last_action?)
  end
end

private

def pattern_vars
  pattern = {
    instance:   @instance,
    templates:  @templates,
    variables:  @variables,
    path:       @path,
    owner:      @owner,
    group:      @group,
    mode:       @mode,
    templates_cookbook:   @templates_cookbook
  }
  pattern
end
