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
  @base_directory = new_resource.base_directory || node['logstash']['default']['basedir']
  @install_type = new_resource.install_type || node['logstash']['default']['install_type']
  @version = new_resource.version || node['logstash']['default']['version']
  @checksum = new_resource.checksum || node['logstash']['default']['checksum']
  @source_url = new_resource.source_url || node['logstash']['default']['source_url']
  @repo = new_resource.repo
  @sha = new_resource.sha
  @java_home = new_resource.java_home
  @user = new_resource.user
  @group = new_resource.group
  @useropts = new_resource.user_opts.clone
  @instance_dir = "#{@base_directory}/#{new_resource.name}".clone
  @name = new_resource.name
end

action :create do

  ls_homedir = @useropts[:homedir]
  ls_uid = @useropts[:uid]
  ls_gid = @useropts[:gid]
  ls_source_url = @source_url
  ls_version = @version
  ls_checksum = @checksum
  ls_basedir = @base_directory
  ls_user = @user
  ls_group = @group
  ls_name = @name

  ur = user ls_user do
    home ls_homedir
    system true
    action :create
    manage_home true
    uid ls_uid
  end
  new_resource.updated_by_last_action(ur.updated_by_last_action?)

  gr = group ls_group do
    gid ls_gid
    members ls_user
    append true
    system true
  end
  new_resource.updated_by_last_action(gr.updated_by_last_action?)

  case @install_type
  when 'tarball'
    @run_context.include_recipe 'ark::default'
    arkit = ark ls_name do
      url       ls_source_url
      checksum  ls_checksum
      owner     ls_user
      group     ls_group
      mode      0755
      version   ls_version
      path      ls_basedir
      action    :put
    end
    new_resource.updated_by_last_action(arkit.updated_by_last_action?)

    %w(bin etc lib log tmp etc/conf.d patterns).each do |ldir|
      r = directory "#{@instance_dir}/#{ldir}" do
        action :create
        mode '0755'
        owner ls_user
        group ls_group
      end
      new_resource.updated_by_last_action(r.updated_by_last_action?)
    end

  when 'jar'
    bdr = directory @base_directory do
      action :create
      mode '0755'
      owner ls_user
      group ls_group
    end
    new_resource.updated_by_last_action(bdr.updated_by_last_action?)

    idr = directory @instance_dir do
      action :create
      mode '0755'
      owner ls_user
      group ls_group
    end
    new_resource.updated_by_last_action(idr.updated_by_last_action?)

    %w(bin etc lib log tmp etc/conf.d patterns).each do |ldir|
      r = directory "#{@instance_dir}/#{ldir}" do
        action :create
        mode '0755'
        owner ls_user
        group ls_group
      end
      new_resource.updated_by_last_action(r.updated_by_last_action?)
    end

    rfr = remote_file "#{ls_instance_dir}/lib/logstash-#{ls_version}.jar" do
      owner 'root'
      group 'root'
      mode '0755'
      source ls_source_url
      checksum ls_checksum
    end
    new_resource.updated_by_last_action(rfr.updated_by_last_action?)

    lr = link "#{ls_instance_dir}/lib/logstash.jar" do
      to "#{ls_instance_dir}/lib/logstash-#{ls_version}.jar"
      only_if { new_resource.auto_symlink }
    end
    new_resource.updated_by_last_action(lr.updated_by_last_action?)

  when 'source'
    bdr = directory @base_directory do
      action :create
      mode '0755'
      owner ls_user
      group ls_group
    end
    new_resource.updated_by_last_action(bdr.updated_by_last_action?)

    idr = directory @instance_dir do
      action :create
      mode '0755'
      owner ls_user
      group ls_group
    end
    new_resource.updated_by_last_action(idr.updated_by_last_action?)

    %w(bin etc lib log tmp etc/conf.d patterns).each do |ldir|
      r = directory "#{@instance_dir}/#{ldir}" do
        action :create
        mode '0755'
        owner ls_user
        group ls_group
      end
      new_resource.updated_by_last_action(r.updated_by_last_action?)
    end

    sd = directory "#{@instance_dir}/source" do
      action :create
      owner ls_user
      group ls_group
      mode '0755'
    end
    new_resource.updated_by_last_action(sd.updated_by_last_action?)

    gr = git "#{@instance_dir}/source" do
      repository @repo
      reference @sha
      action :sync
      user ls_user
      group ls_group
    end
    new_resource.updated_by_last_action(gr.updated_by_last_action?)

    source_version = @sha || "v#{@version}"
    er = execute 'build-logstash' do
      cwd "#{@instance_dir}/source"
      environment(JAVA_HOME: @java_home)
      user ls_user # Changed from root cause building as root...WHA?
      command "make clean && make VERSION=#{source_version} jar"
      action :run
      creates "#{@instance_dir}/source/build/logstash-#{source_version}--monolithic.jar"
      not_if "test -f #{@instance_dir}/source/build/logstash-#{source_version}--monolithic.jar"
    end
    new_resource.updated_by_last_action(er.updated_by_last_action?)
    lr = link "#{@instance_dir}/lib/logstash.jar" do
      to "#{@instance_dir}/source/build/logstash-#{source_version}--monolithic.jar"
      only_if { new_resource.auto_symlink }
    end
    new_resource.updated_by_last_action(lr.updated_by_last_action?)
  else
    Chef::Application.fatal!("Unknown install type: #{@install_type}")
  end
end