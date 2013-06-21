require 'berkshelf/vagrant'

if Vagrant::VERSION > "1.2.0"
  # hurruh!   recent version of vagrant,  lets be sexier.


  # Choose your OS, Override with Environment Variables.
  BOX_NAME = ENV['BOX_NAME'] || 'precise64'
  BOX_URI = ENV['BOX_URI']   || 'https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box'

  # Set your box size, Override with Environment Variables.   
  BOX_MEM = ENV['BOX_MEM'] || '1024'
  BOX_CPU = ENV['BOX_CPU'] || '2' # higher number decrease compile times

  # Chef Run List
  if BOX_NAME.match( 'precise|lucid|quantal|ubuntu' ) # Ubuntu
    chef_run_list = %w[ apt ruby java monit git elasticsearch build-essential
                        php::module_curl logstash::server logstash::kibana ]
    OS = "ubuntu"
    setuid = 'logstash'
    setgid = 'adm'
  elsif BOX_NAME.match( 'centos|rhel' ) # RHEL/CentOS
    chef_run_list = %w[ yum::epel java git elasticsearch
                        php::module_curl logstash::server logstash::kibana ]
    OS = "rhel"
    setuid = 'root'
    setgid = 'root'
  else 
    raise "For Automatic OS detection your BOX_NAME must contain one of the following strings: precise,lucid,quantal,ubuntu,centos,rhel"
  end

# Chef JSON
chef_json = {
  languages: {
    ruby: {
      default_version: '1.9.1'
    }
  },
  java: {
    jdk_version: '7'
  },
  elasticsearch: {
    cluster_name: "logstash_vagrant",
    min_mem: '64m',
    max_mem: '64m',
    limits: {
      nofile:  1024,
      memlock: 512
    }
  },
  logstash: {
    server: {
      setuid: setuid,
      setgid: setgid,
      xms: '128m',
      xmx: '128m',
      enable_embedded_es: false,
      install_rabbitmq: false,
      elasticsearch_ip: '127.0.0.1',
      inputs: [
        file: {
          type: 'syslog',
          path: ['/var/log/messages','/var/log/syslog'],
          start_position: 'beginning'
        },
        tcp: {
          type: 'syslog',
          port: 5140
        }
      ],
      filters: [
        grok: {
          type: 'syslog',
          pattern: '%{SYSLOGBASE}'
        },
        date: {
          type: 'syslog',
          match: [ "timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss", "ISO8601" ]
        }
      ],
      outputs: [
        elasticsearch_http: {
          host: '127.0.0.1',
          flush_size: 1
        }
      ]
    },
    kibana: {
      server_name: '0.0.0.0',
      http_port: '8080',
      use_rbenv: false
    }
  }
}



  Vagrant.configure("2") do |config|

    config.berkshelf.enabled = true
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", BOX_MEM] 
        vb.customize ["modifyvm", :id, "--cpus", BOX_CPU]
    end
    config.vm.provider :lxc do |lxc|
      lxc.customize 'cgroup.memory.limit_in_bytes', "#{BOX_MEM}M"
    end

    config.vm.network :forwarded_port, guest: 8080, host: 8080
    config.vm.network :forwarded_port, guest: 9200, host: 9200
    config.vm.network :forwarded_port, guest: 5140, host: 5140

    # Ensure latest Chef is installed for provisioning
    config.omnibus.chef_version = :latest

    config.vm.define :logstash do |config|
      config.vm.box = BOX_NAME
      config.vm.box_url = BOX_URI
      config.vm.hostname = 'logstash'
      config.vm.network :private_network, ip: "33.33.33.10"
      config.ssh.max_tries = 40
      config.ssh.timeout   = 120
      config.ssh.forward_agent = true

      if OS == "rhel" # doesn't play nice with ruby cookbook
        config.vm.provision :shell, :inline => <<-SCRIPT
          yum -y install ruby-devel
          service iptables stop
        SCRIPT
      end

      config.vm.provision :chef_solo do |chef|
        chef.cookbooks_path    = [ '/tmp/logstash-cookbooks' ]
        chef.provisioning_path = '/etc/vagrant-chef'
        chef.log_level         = :debug
        chef.run_list          = chef_run_list
        chef.json              = chef_json
      end
    end
  end
end

Vagrant::Config.run do |config|

  config.vm.define :lucid32 do |dist_config|
    dist_config.vm.box       = 'lucid32'
    dist_config.vm.box_url   = 'http://files.vagrantup.com/lucid32.box'

    dist_config.vm.customize do |vm|
      vm.name        = 'logstash'
      vm.memory_size = 1024
    end

    dist_config.vm.network :bridged, '33.33.33.10'

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
        logstash::kibana
      ]

      chef.json = {
        elasticsearch: {
          cluster_name: "logstash_vagrant",
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
          },
          kibana: {
            server_name: '33.33.33.10',
            http_port: '8080'
          }
        }
      }
    end
  end

  config.vm.define :lucid64 do |dist_config|
    dist_config.vm.box       = 'lucid64'
    dist_config.vm.box_url   = 'http://files.vagrantup.com/lucid64.box'

    dist_config.vm.customize do |vm|
      vm.name        = 'logstash'
      vm.memory_size = 1024
    end

    dist_config.vm.network :bridged, '33.33.33.10'

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
        logstash::kibana
      ]

      chef.json = {
        elasticsearch: {
          cluster_name: "logstash_vagrant",
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
          },
          kibana: {
            server_name: '33.33.33.10',
            http_port: '8080'
          }
        }
      }
    end
  end

  config.vm.define :centos6_32 do |dist_config|
    dist_config.vm.box       = 'centos6_32'
    dist_config.vm.box_url   = 'http://vagrant.sensuapp.org/centos-6-i386.box'

    dist_config.vm.customize do |vm|
      vm.name        = 'logstash'
      vm.memory_size = 1024
    end

    dist_config.vm.network :bridged, '33.33.33.10'

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
        logstash::kibana
      ]

      chef.json = {
        elasticsearch: {
          cluster_name: "logstash_vagrant",
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
