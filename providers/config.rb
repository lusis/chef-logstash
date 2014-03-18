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
  @instance  = new_resource.instance
  if node['logstash']['instance'].key?(@instance)
    attributes = node['logstash']['instance'][@instance]
  else
    attributes = node['logstash']['instance']['default']
  end
  @templates = new_resource.templates           || attributes['config_templates']
  @templates_cookbook = new_resource.templates_cookbook  || attributes['config_templates_cookbook']
  @variables = new_resource.variables           || attributes['config_templates_variables']
  @home      = new_resource.home                || "#{attributes['base_dir']}/#{@instance}"
  @owner     = new_resource.owner               || attributes['user']
  @group     = new_resource.group               || attributes['group']
  @mode      = new_resource.mode                || '0644'
end

action :create do
  conf = conf_vars
  # Chef::Log.info("config vars: #{conf.inspect}")
  conf[:templates].each do |template, file|
    home = "#{node['logstash']['instance'][conf[:instance]]['basedir']}/#{conf[:instance]}"
    tp = template"#{home}/etc/conf.d/#{::File.basename(file).chomp(::File.extname(file))}" do
      source      file
      cookbook    conf[:templates_cookbook]
      owner       conf[:owner]
      group       conf[:group]
      mode        conf[:mode]
      variables   conf[:variables]
      notifies    :restart, "logstash_service[#{conf[:instance]}]"
      action      :create
    end
    new_resource.updated_by_last_action(tp.updated_by_last_action?)
  end
end

action :remove do
  conf[:templates].each do |template, file|
    tp = template template do
      action :remove
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
    home:       @home,
    owner:      @owner,
    group:      @group,
    mode:       @mode,
    templates_cookbook:   @templates_cookbook
  }
  conf
end
