# Encoding: utf-8
# Cookbook Name:: logstash
# Resource:: config
# Author:: John E. Vincent
# Copyright 2014, John E. Vincent
# License:: Apache 2.0

actions :create

default_action :create if defined?(default_action)

attribute :instance,    kind_of: String, name_attribute: true
attribute :service_name, kind_of: String
attribute :templates,   kind_of: Hash
attribute :variables,   kind_of: Hash
attribute :owner,       kind_of: String
attribute :group,       kind_of: String
attribute :mode,        kind_of: String
attribute :path,        kind_of: String
attribute :templates_cookbook,    kind_of: String
