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
  @basedir   = Logstash.get_attribute_or_default(node, @instance, 'basedir')
  @templates = new_resource.templates || Logstash.get_attribute_or_default(node, @instance, 'pattern_templates')
  @variables = new_resource.variables || Logstash.get_attribute_or_default(node, @instance, 'pattern_templates_variables')
  @owner     = new_resource.owner || Logstash.get_attribute_or_default(node, @instance, 'user')
  @group     = new_resource.group || Logstash.get_attribute_or_default(node, @instance, 'group')
  @templates_cookbook = new_resource.templates_cookbook || Logstash.get_attribute_or_default(node, @instance, 'pattern_templates_cookbook')
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
