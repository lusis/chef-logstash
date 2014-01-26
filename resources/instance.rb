#
# Cookbook Name:: logstash
# Resource:: instance
# Author:: John E. Vincent
# Copyright 2014, John E. Vincent
# License:: Apache 2.0

actions :create, :delete

default_action :create if defined?(default_action)

attribute :name, :kind_of => String, :name_attribute => true
attribute :base_directory, :kind_of => String, :default => "/opt/logstash"
attribute :install_type, :kind_of => String, :equal_to => ["source", "jar"], :default => 'jar'
attribute :auto_symlink, :kind_of => [TrueClass, FalseClass], :default => true
# version/checksum/source_url used by `jar` install_type
attribute :version, :kind_of => String
attribute :checksum, :kind_of => String
attribute :source_url, :kind_of => String
# sha/repo/java_home used by `source` install_type
attribute :sha, :kind_of => String, :default => 'HEAD'
attribute :repo, :kind_of => String, :default => 'git://github.com/logstash/logstash.git'
attribute :java_home, :kind_of => String, :default => '/usr/lib/jvm/java-6-openjdk' #openjdk6 on ubuntu
attribute :user, :kind_of => String, :default => "logstash"
attribute :group, :kind_of => String, :default => "logstash"
attribute :user_opts, :kind_of => Hash, :default => {:homedir => "/var/lib/logstash", :uid => nil, :gid => nil} 
