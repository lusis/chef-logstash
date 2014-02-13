# Encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :

log_level = :info

chef_run_list = %w[
        logstash::server
]
#        curl::default
#        minitest-handler::default
#        logstash::server
#        logstash::agent
#        ark::default
#        kibana::default
#      ]

chef_json = {
    java: {
      jdk_version: '7'
    },
    kibana: {
        webserver_listen: '0.0.0.0',
        webserver: 'nginx',
        install_type: 'file'
    },
    logstash: {
        supervisor_gid: 'adm',
        agent: {
            server_ipaddress: '127.0.0.1',
            xms: '128m',
            xmx: '128m',
            enable_embedded_es: false,
            inputs: [
              file: {
                type: 'syslog',
                path: ['/var/log/syslog', '/var/log/messages'],
                start_position: 'beginning'
              }
            ],
            filters: [
              {
                condition: 'if [type] == "syslog"',
                block: {
                  grok: {
                    match: [
                      'message',
                      "%{SYSLOGTIMESTAMP:timestamp} %{IPORHOST:host} (?:%{PROG:program}(?:\[%{POSINT:pid}\])?: )?%{GREEDYDATA:message}"
                    ]
                  },
                  date: {
                    match: [
                      'timestamp',
                      'MMM  d HH:mm:ss',
                      'MMM dd HH:mm:ss',
                      'ISO8601'
                    ]
                  }
                }
            }
          ]
        },
        server: {
            xms: '128m',
            xmx: '128m',
            enable_embedded_es: true,
            config_templates: ['apache'],
            config_templates_variables: { apache: { type: 'apache' } },
            web: { enable: true },
            install_method: 'repo',
            init_method: 'native',
            patterns_dir: '/etc/logstash/patterns',
            config_dir: '/etc/logstash/conf.d'
        }
    }
}

Vagrant.configure('2') do |config|

  # Common Settings
  config.omnibus.chef_version = 'latest'
  config.vm.hostname = 'logstash'
  config.vm.network 'forwarded_port', guest: 9292, host: 9292
  config.vm.network 'forwarded_port', guest: 9200, host: 9200
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '1024']
  end
  config.vm.provider :lxc do |lxc|
    lxc.customize 'cgroup.memory.limit_in_bytes', '1024M'
  end

  config.vm.define :precise64 do |dist_config|
    dist_config.vm.box       = 'opscode-ubuntu-12.04'
    dist_config.vm.box_url   = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-12.04_provisionerless.box'

    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level
      chef.run_list = chef_run_list
      chef.json = chef_json
      chef.run_list.unshift('apt')
      chef.json[:logstash][:server][:init_method] = 'runit'
    end
  end

  config.vm.define :lucid64 do |dist_config|
    dist_config.vm.box       = 'lucid64'
    dist_config.vm.box_url   = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04_provisionerless.box'

    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level
      chef.run_list = chef_run_list
      chef.json = chef_json
      chef.run_list.unshift('apt')
      chef.json[:logstash][:server][:init_method] = 'runit'
    end
  end
  config.vm.define :lucid32 do |dist_config|
    dist_config.vm.box       = 'lucid32'
    dist_config.vm.box_url   = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_ubuntu-10.04-i386_provisionerless.box'
    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level
      chef.run_list = chef_run_list
      chef.json = chef_json
      chef.run_list.unshift('apt')
      chef.json[:logstash][:server][:init_method] = 'runit'
    end
  end

  config.vm.define :centos6_64 do |dist_config|
    dist_config.vm.box       = 'opscode-centos-6.3' # centos6_64'
    dist_config.vm.box_url   = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4_provisionerless.box'
    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level
      chef.run_list = chef_run_list
      chef.json = chef_json
    end
  end
  config.vm.define :centos6_32 do |dist_config|
    dist_config.vm.box       = 'centos6_32'
    dist_config.vm.box_url   = 'https://opscode-vm-bento.s3.amazonaws.com/vagrant/opscode_centos-6.4-i386_provisionerless.box'
    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level
      chef.run_list = chef_run_list
      chef.json = chef_json
    end
  end

  config.vm.define :fedora18 do |dist_config|
    dist_config.vm.box       = 'fedora18'
    dist_config.vm.box_url   = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_fedora-18_chef-provisionerless.box'
    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level
      chef.run_list = chef_run_list
      chef.json = chef_json
    end
  end

end
