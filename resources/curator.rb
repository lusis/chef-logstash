# Encoding: utf-8
# Cookbook Name:: logstash
# Resource:: config
# Author:: John E. Vincent
# Copyright 2014, John E. Vincent
# License:: Apache 2.0

actions :create, :delete

default_action :create if defined?(default_action)

attribute :instance,      kind_of: String, name_attribute: true
attribute :days_to_keep,  kind_of: String
attribute :minute,        kind_of: String
attribute :hour,          kind_of: String
attribute :log_file,      kind_of: String
attribute :user,          kind_of: String
