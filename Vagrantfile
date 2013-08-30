# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

  # Common Settings
  config.omnibus.chef_version = '10.26.0'
  config.vm.hostname = 'logstash'
  config.vm.network :public_network
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '1024']
  end

  config.vm.define :lucid32 do |dist_config|
    dist_config.vm.box       = 'lucid32'
    dist_config.vm.box_url   = 'http://files.vagrantup.com/lucid32.box'

    dist_config.vm.provision :chef_solo do |chef|

      chef.cookbooks_path    = [ '/tmp/logstash-cookbooks' ]
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level         = :debug

      chef.run_list = %w[
        minitest-handler
        apt
        java
        monit
        erlang
        git
        elasticsearch
        php::module_curl
        logstash::server
      ]

      chef.json = {
          elasticsearch: {
              cluster_name: 'logstash_vagrant',
              min_mem: '64m',
              max_mem: '64m',
              limits: {
                  nofile:  1024,
                  memlock: 512
              }
          },
          logstash: {
              server: {
                  xms: '128m',
                  xmx: '128m',
                  enable_embedded_es: false,
                  elasticserver_ip: '127.0.0.1',
                  init_method: 'runit'
              }        }
      }
    end
  end

  config.vm.define :lucid64 do |dist_config|
    dist_config.vm.box       = 'lucid64'
    dist_config.vm.box_url   = 'http://files.vagrantup.com/lucid64.box'

    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path    = [ '/tmp/logstash-cookbooks' ]
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level         = :debug

      chef.run_list = %w[
        minitest-handler
        apt
        java
        monit
        erlang
        git
        elasticsearch
        php::module_curl
        logstash::server
      ]

      chef.json = {
          elasticsearch: {
              cluster_name: 'logstash_vagrant',
              min_mem: '64m',
              max_mem: '64m',
              limits: {
                  nofile:  1024,
                  memlock: 512
              }
          },
          logstash: {
              server: {
                  xms: '128m',
                  xmx: '128m',
                  enable_embedded_es: false,
                  elasticserver_ip: '127.0.0.1',
                  init_method: 'runit'
              }
          }
      }
    end
  end

  config.vm.define :centos6_32 do |dist_config|
    dist_config.vm.box       = 'centos6_32'
    dist_config.vm.box_url   = 'http://vagrant.sensuapp.org/centos-6-i386.box'

    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path    = [ '/tmp/logstash-cookbooks' ]
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level         = :debug

      chef.run_list = %w[
        minitest-handler
        java
        yum::epel
        erlang
        git
        elasticsearch
        php::module_curl
        logstash::server
      ]

      chef.json = {
          elasticsearch: {
              cluster_name: 'logstash_vagrant',
              min_mem: '64m',
              max_mem: '64m',
              limits: {
                  nofile:  1024,
                  memlock: 512
              }
          },
          logstash: {
              server: {
                  xms: '128m',
                  xmx: '128m',
                  enable_embedded_es: false,
                  elasticserver_ip: '127.0.0.1'
              }
          }
      }
    end
  end
end

