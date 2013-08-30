# -*- mode: ruby -*-
# vi: set ft=ruby :

log_level = :info

server_run_list = %w[
        minitest-handler
        elasticsearch
        logstash::server
      ]

chef_json = {
    elasticsearch: {
        cluster_name: 'logstash_vagrant',
        min_mem: '64m',
        max_mem: '64m',
        limits: {
            nofile: 1024,
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

      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level

      chef.run_list = server_run_list
      chef.run_list.unshift('apt')

      chef.json = chef_json
      chef.json[:logstash][:server][:init_method] = 'runit'
    end
  end

  config.vm.define :lucid64 do |dist_config|
    dist_config.vm.box       = 'lucid64'
    dist_config.vm.box_url   = 'http://files.vagrantup.com/lucid64.box'

    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level

      chef.run_list = server_run_list
      chef.run_list.unshift('apt')

      chef.json = chef_json
      chef.json[:logstash][:server][:init_method] = 'runit'
    end
  end

  config.vm.define :centos6_32 do |dist_config|
    dist_config.vm.box       = 'centos6_32'
    dist_config.vm.box_url   = 'http://vagrant.sensuapp.org/centos-6-i386.box'

    dist_config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level

      chef.run_list = server_run_list

      chef.json = chef_json
    end
  end

  config.vm.define :source do |dist_config|
    dist_config.vm.box       = 'lucid32'
    dist_config.vm.box_url = 'http://files.vagrantup.com/lucid32.box'

    dist_config.vm.provision :chef_solo do |chef|

      chef.cookbooks_path = ['/tmp/logstash-cookbooks']
      chef.provisioning_path = '/etc/vagrant-chef'
      chef.log_level = log_level

      chef.run_list = server_run_list
      chef.run_list.unshift('apt')

      chef.json = chef_json
      chef.json[:logstash][:server][:init_method] = 'runit'
      chef.json[:logstash][:server][:install_method] = 'source'
    end
  end
end

