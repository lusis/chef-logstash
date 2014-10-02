# Encoding: utf-8
# Cookbook Name:: logstash
# Provider:: instance
# Author:: John E. Vincent
# License:: Apache 2.0
#
# Copyright 2014, John E. Vincent

require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def load_current_resource
  @name = new_resource.name || 'default'
  @base_directory = new_resource.base_directory || Logstash.get_attribute_or_default(node, @name, 'basedir')
  @install_type = new_resource.install_type || Logstash.get_attribute_or_default(node, @name, 'install_type')
  @version = new_resource.version || Logstash.get_attribute_or_default(node, @name, 'version')
  @checksum = new_resource.checksum || Logstash.get_attribute_or_default(node, @name, 'checksum')
  @source_url = new_resource.source_url || Logstash.get_attribute_or_default(node, @name, 'source_url')
  @repo = new_resource.repo
  @sha = new_resource.sha
  @java_home = new_resource.java_home || Logstash.get_attribute_or_default(node, @name, 'java_home')
  @create_account = new_resource.create_account || Logstash.get_attribute_or_default(node, @name, 'create_account')
  @user = new_resource.user || Logstash.get_attribute_or_default(node, @name, 'user')
  @group = new_resource.group || Logstash.get_attribute_or_default(node, @name, 'group')
  @useropts = new_resource.user_opts || Logstash.get_attribute_or_default(node, @name, 'user_opts')
  @instance_dir = "#{@base_directory}/#{new_resource.name}".clone
  @logrotate_size = new_resource.user_opts || Logstash.get_attribute_or_default(node, @name, 'logrotate_max_size')
  @logrotate_use_filesize = new_resource.logrotate_use_filesize || Logstash.get_attribute_or_default(node, @name, 'logrotate_use_filesize')
  @logrotate_frequency = new_resource.logrotate_frequency || Logstash.get_attribute_or_default(node, @name, 'logrotate_frequency')
  @logrotate_max_backup = new_resource.logrotate_max_backup || Logstash.get_attribute_or_default(node, @name, 'logrotate_max_backup')
  @logrotate_options = new_resource.logrotate_options || Logstash.get_attribute_or_default(node, @name, 'logrotate_options')
  @logrotate_enable = new_resource.logrotate_enable || Logstash.get_attribute_or_default(node, @name, 'logrotate_enable')
end

action :delete do
  ls = ls_vars

  idr = directory ls[:instance_dir] do
    recursive   true
    action      :delete
  end
  new_resource.updated_by_last_action(idr.updated_by_last_action?)
end

action :create do
  ls = ls_vars

  if  ls[:create_account]
    ur = user ls[:user] do
      home ls[:homedir]
      system true
      action :create
      manage_home true
      uid ls[:uid]
    end
    new_resource.updated_by_last_action(ur.updated_by_last_action?)

    gr = group ls[:group] do
      gid ls[:gid]
      members ls[:user]
      append true
      system true
    end
    new_resource.updated_by_last_action(gr.updated_by_last_action?)
  end

  case @install_type
  when 'tarball'
    @run_context.include_recipe 'ark::default'
    arkit = ark ls[:name] do
      url       ls[:source_url]
      checksum  ls[:checksum]
      owner     ls[:user]
      group     ls[:group]
      mode      0755
      version   ls[:version]
      path      ls[:basedir]
      action    :put
    end
    new_resource.updated_by_last_action(arkit.updated_by_last_action?)

    %w(bin etc lib log tmp etc/conf.d patterns).each do |ldir|
      r = directory "#{ls[:instance_dir]}/#{ldir}" do
        action :create
        mode '0755'
        owner ls[:user]
        group ls[:group]
      end
      new_resource.updated_by_last_action(r.updated_by_last_action?)
    end

  when 'jar'
    bdr = directory @base_directory do
      action :create
      mode '0755'
      owner ls[:user]
      group ls[:group]
    end
    new_resource.updated_by_last_action(bdr.updated_by_last_action?)

    idr = directory ls[:instance_dir] do
      action :create
      mode '0755'
      owner ls[:user]
      group ls[:group]
    end
    new_resource.updated_by_last_action(idr.updated_by_last_action?)

    %w(bin etc lib log tmp etc/conf.d patterns).each do |ldir|
      r = directory "#{ls[:instance_dir]}/#{ldir}" do
        action :create
        mode '0755'
        owner ls[:user]
        group ls[:group]
      end
      new_resource.updated_by_last_action(r.updated_by_last_action?)
    end

    rfr = remote_file "#{ls[:instance_dir]}/lib/logstash-#{ls[:version]}.jar" do
      owner ls[:user]
      group ls[:group]
      mode '0755'
      source ls[:source_url]
      checksum ls[:checksum]
    end
    new_resource.updated_by_last_action(rfr.updated_by_last_action?)

    lr = link "#{ls[:instance_dir]}/lib/logstash.jar" do
      to "#{ls[:instance_dir]}/lib/logstash-#{ls[:version]}.jar"
      only_if { new_resource.auto_symlink }
    end
    new_resource.updated_by_last_action(lr.updated_by_last_action?)

  when 'source'
    bdr = directory @base_directory do
      action :create
      mode '0755'
      owner ls[:user]
      group ls[:group]
    end
    new_resource.updated_by_last_action(bdr.updated_by_last_action?)

    idr = directory ls[:instance_dir] do
      action :create
      mode '0755'
      owner ls[:user]
      group ls[:group]
    end
    new_resource.updated_by_last_action(idr.updated_by_last_action?)

    %w(bin etc lib log tmp etc/conf.d patterns).each do |ldir|
      r = directory "#{ls[:instance_dir]}/#{ldir}" do
        action :create
        mode '0755'
        owner ls[:user]
        group ls[:group]
      end
      new_resource.updated_by_last_action(r.updated_by_last_action?)
    end

    sd = directory "#{ls[:instance_dir]}/source" do
      action :create
      owner ls[:user]
      group ls[:group]
      mode '0755'
    end
    new_resource.updated_by_last_action(sd.updated_by_last_action?)

    gr = git "#{ls[:instance_dir]}/source" do
      repository @repo
      reference @sha
      action :sync
      user ls[:user]
      group ls[:group]
    end
    new_resource.updated_by_last_action(gr.updated_by_last_action?)

    source_version = @sha || "v#{@version}"
    er = execute 'build-logstash' do
      cwd "#{ls[:instance_dir]}/source"
      environment(JAVA_HOME: @java_home)
      user ls_user # Changed from root cause building as root...WHA?
      command "make clean && make VERSION=#{source_version} jar"
      action :run
      creates "#{ls[:instance_dir]}/source/build/logstash-#{source_version}--monolithic.jar"
      not_if "test -f #{ls[:instance_dir]}/source/build/logstash-#{source_version}--monolithic.jar"
    end
    new_resource.updated_by_last_action(er.updated_by_last_action?)
    lr = link "#{ls[:instance_dir]}/lib/logstash.jar" do
      to "#{ls[:instance_dir]}/source/build/logstash-#{source_version}--monolithic.jar"
      only_if { new_resource.auto_symlink }
    end
    new_resource.updated_by_last_action(lr.updated_by_last_action?)
  else
    Chef::Application.fatal!("Unknown install type: #{@install_type}")
  end
  logrotate(ls) if ls[:logrotate_enable]

end

private

def logrotate(ls)
  name = ls[:name]

  @run_context.include_recipe 'logrotate::default'

  logrotate_app "logstash_#{name}" do
    path "#{ls[:instance_dir]}/log/*.log"
    size ls[:logrotate_size] if ls[:logrotate_use_filesize]
    frequency ls[:logrotate_frequency]
    rotate ls[:logrotate_max_backup]
    options ls[:logrotate_options]
    create "664 #{ls[:user]} #{ls[:group]}"
  end
end

def ls_vars
  ls = {
    homedir: @useropts[:homedir],
    uid: @useropts[:uid],
    gid: @useropts[:gid],
    source_url: @source_url,
    version: @version,
    checksum: @checksum,
    basedir: @base_directory,
    create_account: @create_account,
    user: @user,
    group: @group,
    name: @name,
    instance_dir: @instance_dir,
    enable_logrotate: @enable_logrotate,
    logrotate_size: @logrotate_size,
    logrotate_use_filesize: @logrotate_use_filesize,
    logrotate_frequency: @logrotate_frequency,
    logrotate_max_backup: @logrotate_max_backup,
    logrotate_options: @logrotate_options,
    logrotate_enable: @logrotate_enable
  }
  ls
end
