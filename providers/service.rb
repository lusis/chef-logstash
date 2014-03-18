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

action :create do
  svc_name = @instance
  svc_service_name = @service_name
  svc_home = @home
  svc_method = @method
  svc_command = @command
  svc_args = @args
  svc_description = @description
  svc_chdir = @chdir
  svc_user = @user
  svc_group = @group
  services = [svc_name]
  services << 'web' if node['logstash']['server']['web']['enable']
  Chef::Log.info("Using init method #{svc_method} for #{svc_service_name}")
  case svc_method
  when 'pleaserun'
    @run_context.include_recipe 'pleaserun::default'
    pr = pleaserun svc_service_name do
      name        svc_service_name
      program     svc_command
      args        svc_args
      description svc_description
      chdir       svc_chdir
      user        svc_user
      group       svc_group
      action      :create
      not_if { ::File.exists?("/etc/init.d/#{svc_service_name}") }
    end
    new_resource.updated_by_last_action(pr.updated_by_last_action?)
  when 'runit'
    @run_context.include_recipe 'runit::default'
    ri = runit_service(svc_service_name)
    new_resource.updated_by_last_action(ri.updated_by_last_action?)
  when 'native'
      if platform_family? 'debian'
        if node['platform_version'] >= '12.04'
          tp = template "/etc/init/#{svc_service_name}.conf" do
            mode '0644'
            source 'init/upstart.erb'
            variables(
              home: "#{node['logstash']['instance'][svc_name]['basedir']}/#{svc_name}",
              name: svc_name,
              command: svc_command

            )
          end
          new_resource.updated_by_last_action(tp.updated_by_last_action?)
          #sv = service "#{svc_service_name}" do
          #  provider Chef::Provider::Service::Upstart
          #  action [:enable, :start]
          #end
          #new_resource.updated_by_last_action(sv.updated_by_last_action?)
        else
          Chef::Log.fatal("Please set node['logstash']['server']['init_method'] to 'runit' for #{node['platform_version']}")
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
        tp = template "/etc/init.d/#{svc_service_name}" do
          source "init.#{svc_service_name}.erb"
          owner 'root'
          group 'root'
          mode '0774'
          variables(config_file: node['logstash']['server']['config_dir'],
                    home: node['logstash']['server']['home'],
                    name: svc_name,
                    log_file: node['logstash']['server']['log_file'],
                    max_heap: node['logstash']['server']['xmx'],
                    min_heap: node['logstash']['server']['xms']
                    )
        end
        new_resource.updated_by_last_action(tp.updated_by_last_action?)

        sv = service "#{svc_service_name}" do
          supports restart: true, reload: true, status: true
          action [:enable, :start]
        end
        new_resource.updated_by_last_action(sv.updated_by_last_action?)
      end
  else
    Chef::Log.fatal("Unsupported init method: #{@svc_method}")
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
