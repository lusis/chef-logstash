# Encoding: utf-8
#
# Cookbook Name:: logstash
# Definition:: instance
#
# An instance of logstash running on a target node
#

define :instance, :services => [], :conf_variables => {} do
  include_recipe 'java'
  include_recipe 'logstash::default'
  include_recipe 'logrotate'
  include_recipe 'rabbitmq' if node['logstash']['install_rabbitmq']
  include_recipe 'yum::default'

  name = params[:name]
  home_dir = node['logstash'][name]['home']

  log_dir = ::File.dirname node['logstash'][name]['log_file']

  if node['logstash'][name]['init_method'] == 'runit'
    include_recipe 'runit'
    service_resource = "runit_service[logstash_#{name}]"
  else
    service_resource = "service[logstash_#{name}]"
  end

  if node['logstash'][name]['patterns_dir'][0] == '/'
    patterns_dir = node['logstash'][name]['patterns_dir']
  else
    patterns_dir = node['logstash'][name]['home'] + '/' + node['logstash'][name]['patterns_dir']
  end

  params[:conf_variables][:patterns_dir] = patterns_dir

  if node['logstash']['install_zeromq']
    include_recipe 'logstash::zero_mq_repo'
    node['logstash']['zeromq_packages'].each { |p| package p }
  end

  # absolute directories
  [home_dir, patterns_dir, log_dir].each do |adir|
    directory adir do
      action :create
      mode '0755'
      owner node['logstash']['user']
      group node['logstash']['group']
      recursive true
    end
  end

  # subdirectories of home_dir
  %w{bin etc lib log tmp etc/conf.d}.each do |ldir|
    directory "#{home_dir}/#{ldir}" do
      action :create
      mode '0755'
      owner node['logstash']['user']
      group node['logstash']['group']
    end
  end

  node['logstash']['patterns'].each do |file, hash|
    template_name = patterns_dir + '/' + file
    template template_name do
      source 'patterns.erb'
      owner node['logstash']['user']
      group node['logstash']['group']
      variables(:patterns => hash)
      mode '0644'
      notifies :restart, service_resource
    end
  end

  # installation
  if node['logstash'][name]['install_method'] == 'jar'
    remote_file "#{node['logstash'][name]['home']}/lib/logstash-#{node['logstash'][name]['version']}.jar" do
      owner 'root'
      group 'root'
      mode '0755'
      source node['logstash'][name]['source_url']
      checksum node['logstash'][name]['checksum']
      action :create_if_missing
    end

    link "#{node['logstash'][name]['home']}/lib/logstash.jar" do
      to "#{node['logstash'][name]['home']}/lib/logstash-#{node['logstash'][name]['version']}.jar"
      notifies :restart, service_resource
    end
  else
    include_recipe 'logstash::source'

    logstash_version = node['logstash']['source']['sha'] || "v#{node['logstash'][name]['version']}"
    link "#{node['logstash'][name]['home']}/lib/logstash.jar" do
      to "#{node['logstash']['basedir']}/source/build/logstash-#{logstash_version}-monolithic.jar"
      notifies :restart, service_resource
    end
  end

  unless node['logstash'][name]['config_templates'].empty? || node['logstash'][name]['config_templates'].nil?
    node['logstash'][name]['config_templates'].each do |config_template|
      template "#{node['logstash'][name]['home']}/#{node['logstash'][name]['config_dir']}/#{config_template}.conf" do
        source "#{config_template}.conf.erb"
        cookbook node['logstash'][name]['config_templates_cookbook']
        owner node['logstash']['user']
        group node['logstash']['group']
        mode '0644'
        variables node['logstash'][name]['config_templates_variables'][config_template]
        notifies :restart, service_resource
        action :create
      end
    end
  end

  template "#{node['logstash'][name]['home']}/#{node['logstash'][name]['config_dir']}/#{node['logstash'][name]['config_file']}" do
    source node['logstash'][name]['base_config']
    cookbook node['logstash'][name]['base_config_cookbook']
    owner node['logstash']['user']
    group node['logstash']['group']
    mode '0644'
    variables params[:conf_variables]
    notifies :restart, service_resource
    only_if { node['logstash'][name]['config_file'] }
  end

  logrotate_app "logstash_#{name}" do
    path "#{log_dir}/*.log"
    
    size node['logstash']['logging']['maxSize'] if node['logstash']['logging']['useFileSize']
    frequency node['logstash']['logging']['rotateFrequency']
    rotate node['logstash']['logging']['maxBackup']
    options node['logstash'][name]['logrotate']['options']
    create "664 #{node['logstash']['user']} #{node['logstash']['group']}"
    notifies :restart, 'service[rsyslog]'
    if node['logstash'][name]['logrotate']['stopstartprepost']
      prerotate <<-EOF
        service logstash_#{name} stop
        logger stopped logstash_#{name} service for log rotation
      EOF
      postrotate <<-EOF
        service logstash_#{name} start
        logger started logstash_#{name} service after log rotation
      EOF
    end
  end

  params[:services].each do |type|
    if node['logstash'][name]['init_method'] == 'runit'
      runit_service("logstash_#{type}")
    elsif node['logstash'][name]['init_method'] == 'native'
      if platform_family? 'debian'
        if node['platform_version'] >= '12.04'
          template "/etc/init/logstash_#{type}.conf" do
            mode '0644'
            source "logstash_#{type}.conf.erb"
          end

          service "logstash_#{type}" do
            provider Chef::Provider::Service::Upstart
            action [:enable, :start]
          end
        else
          Chef::Log.fatal("Please set node['logstash'][#{name}]['init_method'] to 'runit' for #{node['platform_version']}")
        end

      elsif platform_family? 'fedora' && node['platform_version'] >= '15'
        execute 'reload-systemd' do
          command 'systemctl --system daemon-reload'
          action :nothing
        end

        template "/etc/systemd/system/logstash_#{type}.service" do
          source "logstash_#{type}.service.erb"
          owner 'root'
          group 'root'
          mode  '0755'
          notifies :run, 'execute[reload-systemd]', :immediately
          notifies :restart, "service[logstash_#{type}]", :delayed
        end

        service "logstash_#{type}" do
          service_name "logstash_#{type}.service"
          provider Chef::Provider::Service::Systemd
          action [:enable, :start]
        end

      elsif platform_family? 'rhel', 'fedora'
        template "/etc/init.d/logstash_#{type}" do
          source "init.logstash_#{type}.erb"
          owner 'root'
          group 'root'
          mode '0774'
          variables(:config_file => node['logstash'][name]['config_dir'],
                    :home => node['logstash'][name]['home'],
                    :name => type,
                    :log_file => node['logstash'][name]['log_file'],
                    :max_heap => node['logstash'][name]['xmx'],
                    :min_heap => node['logstash'][name]['xms']
                    )
        end

        service "logstash_#{type}" do
          supports :restart => true, :reload => true, :status => true
          action [:enable, :start]
        end
      end
    else
      Chef::Log.fatal("Unsupported init method: #{node['logstash'][name]['init_method']}")
    end
  end
end
