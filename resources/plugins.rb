# Encoding: utf-8
# Cookbook Name:: logstash
# Resource:: instance
# Author:: John E. Vincent
# Copyright 2014, John E. Vincent
# License:: Apache 2.0

actions :create

default_action :create if defined?(default_action)

attribute :name, kind_of: String, name_attribute: true
attribute :instance, kind_of: String
attribute :version, kind_of: String
attribute :checksum, kind_of: String
attribute :source_url, kind_of: String
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :base_directory, kind_of: String
attribute :install_type, kind_of: String, default: 'native'
attribute :install_check, kind_of: String
