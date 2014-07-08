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
  @instance = new_resource.instance
  if node['logstash']['instance'].key?(@instance)
    attributes = node['logstash']['instance'][@instance]
    defaults = node['logstash']['instance']['default']
  else
    attributes = node['logstash']['instance']['default']
  end

  @basedir = attributes['basedir'] || defaults['basedir']
  @templates_cookbook = new_resource.templates_cookbook  || attributes['service_templates_cookbook'] || defaults['service_templates_cookbook']
  @service_name = new_resource.service_name || "logstash_#{@instance}"
  @home = "#{@basedir}/#{@instance}"
  @method = new_resource.method || attributes['init_method'] || defaults['init_method']
  @command = new_resource.command || "#{@home}/bin/logstash"
  @user = new_resource.user || attributes['user'] || defaults['user']
  @group = new_resource.group || attributes['group'] || defaults['group']
  @log_file = attributes['log_file'] || defaults['log_file']
  @max_heap = attributes['xmx'] || defaults['xmx']
  @min_heap = attributes['xms'] || defaults['xms']
  @gc_opts = attributes['gc_opts'] || defaults['gc_opts']
  @ipv4_only = attributes['ipv4_only'] || defaults['ipv4_only']
  @java_opts = attributes['java_opts'] || defaults['java_opts']
  @description = new_resource.description || @service_name
  @chdir = @home
  @workers =  attributes['workers'] || defaults['workers']
  @debug =  attributes['debug'] || defaults['debug']
  @install_type = attributes['install_type'] || defaults['install_type']
  @supervisor_gid = attributes['supervisor_gid'] || defaults['supervisor_gid']
end

action :restart do
  svc = svc_vars
  case svc[:method]
  when 'native'
    sv = service svc[:service_name] do
      # provider Chef::Provider::Service::Upstart
      action [:restart]
    end
    new_resource.updated_by_last_action(sv.updated_by_last_action?)
  end
end

action :start do
  svc = svc_vars
  case svc[:method]
  when 'native'
    sv = service svc[:service_name] do
      # provider Chef::Provider::Service::Upstart
      action [:start]
    end
    new_resource.updated_by_last_action(sv.updated_by_last_action?)
  end
end

action :stop do
  svc = svc_vars
  case svc[:method]
  when 'native'
    sv = service svc[:service_name] do
      # provider Chef::Provider::Service::Upstart
      action [:stop]
    end
    new_resource.updated_by_last_action(sv.updated_by_last_action?)
  end
end

action :reload do
  svc = svc_vars
  case svc[:method]
  when 'native'
    sv = service svc[:service_name] do
      # provider Chef::Provider::Service::Upstart
      action [:reload]
    end
    new_resource.updated_by_last_action(sv.updated_by_last_action?)
  end
end

action :enable do
  svc = svc_vars
  Chef::Log.info("Using init method #{svc[:method]} for #{svc[:service_name]}")
  case svc[:method]
  when 'pleaserun'
    @run_context.include_recipe 'pleaserun::default'
    pr = pleaserun svc[:service_name] do
      name        svc[:service_name]
      program     svc[:command]
      args        default_args
      description svc[:description]
      chdir       svc[:chdir]
      user        svc[:user]
      group       svc[:group]
      action      :create
      not_if { ::File.exist?("/etc/init.d/#{svc[:service_name]}") }
    end
    new_resource.updated_by_last_action(pr.updated_by_last_action?)
  when 'runit'
    @run_context.include_recipe 'runit::default'
    ri = runit_service svc[:service_name] do
      options(
                name: svc[:name],
                home: svc[:home],
                max_heap: svc[:max_heap],
                min_heap: svc[:min_heap],
                gc_opts: svc[:gc_opts],
                java_opts: svc[:java_opts],
                ipv4_only: svc[:ipv4_only],
                debug: svc[:debug],
                log_file: svc[:log_file],
                workers: svc[:workers],
                install_type: svc[:install_type],
                supervisor_gid: svc[:supervisor_gid],
                user: svc[:user],
                web_address: svc[:web_address],
                web_port: svc[:web_port]
      )
      cookbook  svc[:templates_cookbook]
    end
    new_resource.updated_by_last_action(ri.updated_by_last_action?)
  when 'native'
    if platform_family? 'debian'
      if node['platform_version'] >= '12.04'
        args = default_args
        tp = template "/etc/init/#{svc[:service_name]}.conf" do
          mode      '0644'
          source    "init/#{svc[:install_type]}_upstart.erb"
          cookbook  svc[:templates_cookbook]
          variables(
                      home: svc[:home],
                      name: svc[:name],
                      command: svc[:command],
                      args: args,
                      user: svc[:user],
                      group: svc[:group],
                      description: svc[:description],
                      max_heap: svc[:max_heap],
                      min_heap: svc[:min_heap],
                      gc_opts: svc[:gc_opts],
                      java_opts: svc[:java_opts],
                      ipv4_only: svc[:ipv4_only],
                      debug: svc[:debug],
                      log_file: svc[:log_file],
                      workers: svc[:workers],
                      supervisor_gid: svc[:supervisor_gid]
                    )
        end
        new_resource.updated_by_last_action(tp.updated_by_last_action?)
        sv = service svc[:service_name] do
          provider Chef::Provider::Service::Upstart
          supports restart: true, reload: true, start: true, stop: true
          action [:enable]
        end
        new_resource.updated_by_last_action(sv.updated_by_last_action?)
      else
        Chef::Log.fatal("Please set node['logstash']['instance']['server']['init_method'] to 'runit' for #{node['platform_version']}")
      end
    elsif (platform_family? 'fedora') && (node['platform_version'] >= '15')
      ex = execute 'reload-systemd' do
        command 'systemctl --system daemon-reload'
        action :nothing
      end
      new_resource.updated_by_last_action(ex.updated_by_last_action?)
      template '/etc/systemd/system/logstash_server.service' do
        tp = source 'logstash_server.service.erb'
        cookbook  svc[:templates_cookbook]
        owner 'root'
        group 'root'
        mode '0755'
        notifies :run, 'execute[reload-systemd]', :immediately
        notifies :restart, 'service[logstash_server]', :delayed
      end
      new_resource.updated_by_last_action(tp.updated_by_last_action?)

      sv = service 'logstash_server' do
        service_name 'logstash_server.service'
        provider Chef::Provider::Service::Systemd
        action [:enable, :start]
      end
      new_resource.updated_by_last_action(sv.updated_by_last_action?)

    elsif platform_family? 'rhel', 'fedora'
      args = default_args
      tp = template "/etc/init.d/#{svc[:service_name]}" do
        source "init/#{svc[:install_type]}_init.logstash.erb"
        cookbook  svc[:templates_cookbook]
        owner 'root'
        group 'root'
        mode '0774'
        variables(
                  home: svc[:home],
                  name: svc[:name],
                  command: svc[:command],
                  args: args,
                  user: svc[:user],
                  group: svc[:group],
                  description: svc[:description],
                  max_heap: svc[:max_heap],
                  min_heap: svc[:min_heap],
                  gc_opts: svc[:gc_opts],
                  java_opts: svc[:java_opts],
                  ipv4_only: svc[:ipv4_only],
                  debug: svc[:debug],
                  log_file: svc[:log_file],
                  workers: svc[:workers],
                  supervisor_gid: svc[:supervisor_gid],
                  config_file: "#{svc[:home]}/etc/conf.d",
                  group: svc[:group]
                  )
      end
      new_resource.updated_by_last_action(tp.updated_by_last_action?)

      sv = service svc[:service_name] do
        supports restart: true, reload: true, status: true
        action [:enable, :start]
      end
      new_resource.updated_by_last_action(sv.updated_by_last_action?)
    end
  else
    Chef::Log.fatal("Unsupported init method: #{@svc[:method]}")
  end
end

private

def default_args
  svc = svc_vars
  args      = ['agent', '-f', "#{svc[:home]}/etc/conf.d/"]
  args.concat ['-vv'] if svc[:debug]
  args.concat ['-l', "#{svc[:home]}/log/#{svc[:log_file]}"] if svc[:log_file]
  args.concat ['-w', svc[:workers].to_s] if svc[:workers]
  args
end

def svc_vars
  svc = {
    name: @instance,
    service_name: @service_name,
    home: @home,
    method: @method,
    command: @command,
    description: @description,
    chdir: @chdir,
    user: @user,
    group: @group,
    log_file: @log_file,
    max_heap: @max_heap,
    min_heap: @min_heap,
    java_opts: @java_opts,
    ipv4_only: @ipv4_only,
    workers: @workers,
    debug: @debug,
    install_type: @install_type,
    supervisor_gid: @supervisor_gid,
    templates_cookbook: @templates_cookbook
  }
  svc
end
