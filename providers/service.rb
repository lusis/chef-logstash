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
  @service_name = new_resource.service_name || "logstash_#{@instance}"
  @home = "#{node['logstash']['instance'][@instance]['basedir']}/#{@instance}"
  @method = new_resource.method || node['logstash']['instance'][@instance]['init_method']
  @command = new_resource.command || "#{@home}/bin/logstash"
  @args = new_resource.args || default_args
  @description = new_resource.description || @service_name
  @chdir = new_resource.chdir || @home
  @user = new_resource.user || node['logstash']['instance'][@instance]['user']
  @group = new_resource.group || node['logstash']['instance'][@instance]['group']
end

action :restart do
  svc = svc_vars
  case svc[:method]
  when 'native'
    sv = service svc[:service_name] do
      provider Chef::Provider::Service::Upstart
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
      provider Chef::Provider::Service::Upstart
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
      provider Chef::Provider::Service::Upstart
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
      provider Chef::Provider::Service::Upstart
      action [:reload]
    end
    new_resource.updated_by_last_action(sv.updated_by_last_action?)
  end
end

action :enable do
  svc = svc_vars
  Chef::Log.info("Using init method #{svc[:method]} for #{svc[:service_name]} - #{svc.inspect}")
  case svc[:method]
  when 'pleaserun'
    @run_context.include_recipe 'pleaserun::default'
    pr = pleaserun svc[:service_name] do
      name        svc[:service_name]
      program     svc[:command]
      args        svc[:args]
      description svc[:description]
      chdir       svc[:chdir]
      user        svc[:user]
      group       svc[:group]
      action      :create
      not_if { ::File.exists?("/etc/init.d/#{svc[:service_name]}") }
    end
    new_resource.updated_by_last_action(pr.updated_by_last_action?)
  when 'runit'
    @run_context.include_recipe 'runit::default'
    ri = runit_service(svc[:service_name])
    new_resource.updated_by_last_action(ri.updated_by_last_action?)
  when 'native'
    if platform_family? 'debian'
      if node['platform_version'] >= '12.04'
        if node['logstash']['instance'][svc[:name]]['install_type'] == 'tarball'
          tp_source = 'init/binary_upstart.erb'
        else
          tp_source = 'init/java_upstart.erb'
        end
        tp = template "/etc/init/#{svc[:service_name]}.conf" do
          mode      '0644'
          source    tp_source
          variables(home: "#{node['logstash']['instance'][svc[:name]]['basedir']}/#{svc[:name]}",
                    name: svc[:name],
                    command: svc[:command]
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
      tp = template "/etc/init.d/#{svc[:service_name]}" do
        source "init.#{svc[:service_name]}.erb"
        owner 'root'
        group 'root'
        mode '0774'
        variables(config_file: node['logstash']['server']['config_dir'],
                  home: node['logstash']['server']['home'],
                  name: svc[:name],
                  log_file: node['logstash']['server']['log_file'],
                  max_heap: node['logstash']['server']['xmx'],
                  min_heap: node['logstash']['server']['xms']
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
  logstash_home = "#{node['logstash']['instance'][@instance]['basedir']}/#{@instance}"
  args      = ['agent', '-f', "#{node['logstash']['instance'][@instance]['home']}/etc/conf.d/"]
  args.concat ['--pluginpath', node['logstash']['instance'][@instance]['pluginpath']] if node['logstash']['instance'][@instance]['pluginpath']
  args.concat ['-vv'] if node['logstash']['instance'][@instance]['debug']
  args.concat ['-l', "#{logstash_home}/log/#{node['logstash']['instance'][@instance]['log_file']}"] if node['logstash']['instance'][@instance]['log_file']
  args.concat ['-w', node['logstash']['instance'][@instance]['workers'].to_s] if node['logstash']['instance'][@instance]['workers']
  args
end

def svc_vars
  svc = {
    name: @instance,
    service_name: @service_name,
    home: @home,
    method: @method,
    command: @command,
    args: @args,
    description: @description,
    chdir: @chdir,
    user: @user,
    group: @group
  }
  svc
end
