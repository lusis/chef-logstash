# Encoding: utf-8
# Cookbook Name:: logstash
# Resource:: instance
# Author:: John E. Vincent
# Copyright 2014, John E. Vincent
# License:: Apache 2.0

actions :create, :delete

default_action :create if defined?(default_action)

attribute :name, kind_of: String, name_attribute: true
attribute :base_directory, kind_of: String
attribute :install_type, kind_of: String
attribute :auto_symlink, kind_of: [TrueClass, FalseClass], default: true
# version/checksum/source_url used by `jar`, `tarball` install_type
attribute :version, kind_of: String
attribute :checksum, kind_of: String
attribute :source_url, kind_of: String
# sha/repo/java_home used by `source` install_type
attribute :sha, kind_of: String, default: 'HEAD'
attribute :repo, kind_of: String, default: 'git://github.com/logstash/logstash.git'
attribute :java_home, kind_of: String, default: '/usr/lib/jvm/java-6-openjdk' # openjdk6 on ubuntu
attribute :user, kind_of: String
attribute :group, kind_of: String
attribute :logrotate_enable, kind_of: [TrueClass, FalseClass]
attribute :user_opts, kind_of: [Hash]
attribute :logrotate_size, kind_of: [String]
attribute :logrotate_use_filesize, kind_of: [TrueClass, FalseClass]
attribute :logrotate_frequency, kind_of: [String]
attribute :logrotate_max_backup, kind_of: [Integer]
attribute :logrotate_options, kind_of: [String]
