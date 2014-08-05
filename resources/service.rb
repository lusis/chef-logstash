# Encoding: utf-8
# Cookbook Name:: logstash
# Resource:: instance
# Author:: John E. Vincent
# Copyright 2014, John E. Vincent
# License:: Apache 2.0

actions :enable, :start, :restart, :reload, :stop

default_action :enable if defined?(default_action)

attribute :instance, kind_of: String, name_attribute: true
attribute :service_name, kind_of: String
attribute :method, kind_of: String
attribute :command, kind_of: String
attribute :args, kind_of: Array
attribute :description, kind_of: String
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :templates_cookbook,    kind_of: String
