# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'
require 'getoptlong'

class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
end


opts = GetoptLong.new(
  [ '--engine-version', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--help', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '-d', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--force', GetoptLong::OPTIONAL_ARGUMENT ]
)
engine_version=''
#
opts.each do |opt, arg|
    case opt
        when '--engine-version'
              engine_version=arg
    end
end

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

base_box=config['environment']['base_box']

if engine_version == ''
    engine_version=config['environment']['engine_version']
end

#case engine_version
#    when "experimental"
#        engine_download_url="http://experimental.docker,.com"
#
#    when "current", "latest", "stable"
#        engine_download_url="http://get.docker,.com"
#
#    when "test", "testing", "rc"
#        engine_download_url="http://test.docker,.com"
#        
#    else 
#        #\e[41m#{self}\e[0m
#        STDERR.puts "Unknown Docker Engine version, please use 'experimental', 'test' or 'stable'".red
#        exit
#end


swarm_master_ip=config['environment']['swarm_masterip']

domain=config['environment']['domain']

boxes = config['boxes']

boxes_hostsfile_entries=""

 boxes.each do |box|
   boxes_hostsfile_entries=boxes_hostsfile_entries+box['mgmt_ip'] + ' ' +  box['name'] + ' ' + box['name']+'.'+domain+'\n'
 end

#puts boxes_hostsfile_entries

update_hosts = <<SCRIPT
    echo "127.0.0.1 localhost" >/etc/hosts
    echo -e "#{boxes_hostsfile_entries}" |tee -a /etc/hosts
SCRIPT

puts '--------------------------------'
puts 'Docker Engine Version: '+engine_version
puts '--------------------------------'

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if proxy
        puts "Using proxy"
        config.proxy.http = proxy
        config.proxy.https = proxy
        config.proxy.no_proxy = "localhost,127.0.0.1"
    end
  end
  config.vm.box = base_box
  case engine_version
    when "experimental"
        engine_download_url="https://experimental.docker.com"
    when "current", "latest", "stable"
        engine_download_url="https://get.docker.com"
    when "test", "testing", "rc"
        engine_download_url="https://test.docker.com"
    else
        STDERR.puts "Unknown Docker Engine version, please use 'experimental', 'test' or 'stable'".red
         exit
    end

  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
  config.vm.synced_folder "src/", "/src",create:true
  boxes.each do |node|
    config.vm.define node['name'] do |config|
      config.vm.hostname = node['name']
      config.vm.provider "virtualbox" do |v|
        v.name = node['name']
        v.customize ["modifyvm", :id, "--memory", node['mem']]
        v.customize ["modifyvm", :id, "--cpus", node['cpu']]

        v.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
        v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

      end

      config.vm.network "private_network",
      ip: node['mgmt_ip'],
      virtualbox__intnet: "DOCKER_SWARM"


      #  config.vm.network "private_network",
      #  ip: opts[:node_hostonlyip], :netmask => "255.255.255.0",
      #  :name => 'vboxnet0',
      #  :adapter => 2


      config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true

      config.vm.network "public_network",
      bridge: ["enp4s0","wlp3s0","enp3s0f1","wlp2s0"],
      auto_config: true


      config.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update -qq && apt-get install -qq chrony && timedatectl set-timezone Europe/Madrid
      SHELL

      # Delete default router for host-only-adapter
      #  config.vm.provision "shell",
      #  run: "always",
      #  inline: "route del default gw 192.168.56.1"


      ## INSTALL DOCKER ENGINE --> on script because we can reprovision
      #config.vm.provision "shell", inline: <<-SHELL
      #
      #SHELL

      ## ADD HOSTS
      # config.vm.provision "shell", inline: <<-SHELL
      #   echo "127.0.0.1 localhost" >/etc/hosts
      #   echo "10.10.10.11 swarmnode1 swarmnode1.dockerlab.local" >>/etc/hosts
      #   echo "10.10.10.12 swarmnode2 swarmnode2.dockerlab.local" >>/etc/hosts
      #   echo "10.10.10.13 swarmnode3 swarmnode3.dockerlab.local" >>/etc/hosts
      #   echo "10.10.10.14 swarmnode4 swarmnode4.dockerlab.local" >>/etc/hosts
      #
      # SHELL


      config.vm.provision :shell, :inline => update_hosts




      config.vm.provision "file", source: "create_swarm.sh", destination: "/tmp/create_swarm.sh"
      config.vm.provision :shell, :path => 'create_swarm.sh' , :args => [ node['mgmt_ip'], node['swarm_role'], swarm_master_ip, engine_download_url ]

      config.vm.provision "file", source: "install_compose.sh", destination: "/tmp/install_compose.sh"
      config.vm.provision :shell, :path => 'install_compose.sh'
    end
  end

end
