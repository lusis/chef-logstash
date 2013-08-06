require 'berkshelf/vagrant'

if Vagrant::VERSION < "1.2.0"
  raise "The Chef-logstash Vagrant test harness is only compatible with Vagrant 1.2.0+"
end

# Choose your OS, Override with Environment Variables.
BOX_NAME = ENV['BOX_NAME'] || 'precise64'
BOX_URI = ENV['BOX_URI']   || 'https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box'

# Set your box size, Override with Environment Variables.   
BOX_MEM = ENV['BOX_MEM'] || '1024'
BOX_CPU = ENV['BOX_CPU'] || '2' # higher number decrease compile times

# Chef Run List
if BOX_NAME.match( 'precise|lucid|quantal|ubuntu' ) # Ubuntu
  chef_run_list = %w[ apt java monit git elasticsearch build-essential
                      logstash::server kibana ]
  OS = "ubuntu"
elsif BOX_NAME.match( 'centos|rhel' ) # RHEL/CentOS
  chef_run_list = %w[ yum::epel java git elasticsearch
                      logstash::server kibana ]
  OS = "rhel"
else 
  raise "For Automatic OS detection your BOX_NAME must contain one of the following strings: precise,lucid,quantal,ubuntu,centos,rhel"
end

# Chef JSON
chef_json = {
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
      xms: '128m',
      xmx: '128m',
      enable_embedded_es: false,
      install_rabbitmq: false,
      elasticsearch_ip: '127.0.0.1',
      inputs: [
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
    }
  },
  kibana: {
    webserver_port: '8080',
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