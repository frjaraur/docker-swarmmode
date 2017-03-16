# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'
# require 'getoptlong'
require 'fileutils'
require 'shellwords'

class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
end

# if ARGV[0] == "up"
#   unless `ps alx | grep [v]boxwebsrv` != ""
#     printf "starting virtualbox web server\n"
#     print `VBoxManage setproperty websrvauthlibrary null && vboxwebsrv -H 0.0.0.0 --background`
#   end
# end



# opts = GetoptLong.new(
#   [ '--engine-version', GetoptLong::OPTIONAL_ARGUMENT ],
#   [ '--help', GetoptLong::OPTIONAL_ARGUMENT ],
#   [ '-d', GetoptLong::OPTIONAL_ARGUMENT ],
#   [ '--force', GetoptLong::OPTIONAL_ARGUMENT ]
# )
engine_version=''
engine_mode='default'
proxy = ''
#
# opts.each do |opt, arg|
#     case opt
#         when '--engine-version'
#               engine_version=arg
#         when '--engine-mode'
#               engine_mode=arg
#     end
# end

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

base_box=config['environment']['base_box']

if engine_version == ''
    engine_version=config['environment']['engine_version']
end

if engine_mode == 'default'
    engine_mode=config['environment']['engine_mode']
end

swarm_master_ip=config['environment']['swarm_masterip']

domain=config['environment']['domain']

boxes = config['boxes']

boxes_hostsfile_entries=""


## TLS

tls_passphrase = config['environment']['tls_passphrase']

########

boxes.each do |box|
  boxes_hostsfile_entries=boxes_hostsfile_entries+box['mgmt_ip'] + ' ' +  box['name'] + ' ' + box['name']+'.'+domain+'\n'
end

#puts boxes_hostsfile_entries

update_hosts = <<SCRIPT
    echo "127.0.0.1 localhost" >/etc/hosts
    echo -e "#{boxes_hostsfile_entries}" |tee -a /etc/hosts
SCRIPT

puts '-------------------------------------------------------------------'
puts 'Docker Engine Version: '+engine_version+' (mode: '+engine_mode+')'
puts '-------------------------------------------------------------------'

# Added Rex-Ray
$rexray_cfg = "/etc/rexray/config.yml"
$volume_path = "#{File.dirname(__FILE__)}/.vagrant/volumes"
FileUtils::mkdir_p $volume_path
#$write_rexray_config_manager = <<SCRIPT
# 10.0.2.2 is the virtual ip for virtualbox host using vagrant
$write_rexray_config = <<SCRIPT
mkdir -p #{File.dirname($rexray_cfg).shellescape}
cat << EOF > #{$rexray_cfg.shellescape}
rexray:
  logLevel: warn
libstorage:
  service: virtualbox
  integration:
    volume:
      operations:
        mount:
          preempt: true
virtualbox:
  volumePath: #{$volume_path}
  endpoint: http://10.0.2.2:18083
  controllerName: SATA
EOF
SCRIPT

#$write_rexray_config_worker = <<SCRIPT
#mkdir -p #{File.dirname($rexray_cfg).shellescape}
#cat << EOF > #{$rexray_cfg.shellescape}
#rexray:
  #logLevel: warn
#libstorage:
  #host:    tcp://#{$swarm_master_ip}:7979
  #service: virtualbox
#EOF
#SCRIPT


$install_docker_engine = <<SCRIPT
  curl -sSk https://get.docker.com | sh
  usermod -aG docker vagrant 2>/dev/null
SCRIPT

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if proxy != ''
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

	      v.customize ["modifyvm", :id, "--macaddress1", "auto"]

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
        apt-get update -qq && apt-get install -qq chrony curl && timedatectl set-timezone Europe/Madrid
      SHELL

      config.vm.provision :shell, :inline => update_hosts

      ## Docker Install
      puts "Download from " + engine_download_url

      config.vm.provision "shell" do |s|
       			s.name       = "Install Docker Engine from "+engine_download_url
        		s.inline     = $install_docker_engine
      end


      # config.vm.provision "shell", inline: <<-SHELL
      #     apt-get install -qq curl \
      #     && curl -sSk #{$engine_download_url} | sh \
      #     && usermod -aG docker vagrant 2>/dev/null || true
      # SHELL

      

      ## Docker Secure Engine with TLS
      puts "Securing Docker with TLS"

      config.vm.provision "file", source: "create_tls_certs.sh", destination: "/tmp/create_tls_certs.sh"
      config.vm.provision :shell, :path => 'create_tls_certs.sh' , :args => [ tls_passphrase, node['mgmt_ip'], node['hostonly_ip'], node['name']  ]


      ## Create Docker Swarm (Swarm Mode)

      config.vm.provision "file", source: "create_swarm.sh", destination: "/tmp/create_swarm.sh"
      config.vm.provision :shell, :path => 'create_swarm.sh' , :args => [ node['mgmt_ip'], node['swarm_role'], swarm_master_ip, engine_mode ]


      ## Install docker-compose

      config.vm.provision "file", source: "install_compose.sh", destination: "/tmp/install_compose.sh"
      config.vm.provision :shell, :path => 'install_compose.sh'


		  config.vm.provision "shell" do |s|
       			s.name       = "config rex-ray"
        		s.inline     = $write_rexray_config
      end

      # install rex-ray
      config.vm.provision "shell", inline: <<-SHELL
	     curl -sSL https://dl.bintray.com/emccode/rexray/install | sh
	     rexray install
      SHELL


      config.vm.provision "shell" do |s|
        s.name   = "Start rex-ray"
        s.inline = "sudo systemctl start rexray"
      end

      config.vm.provision "shell" do |s|
        s.name   = "Restart Docker Engine"
        s.inline = "sudo systemctl restart docker"
      end

#	config.vm.provision "shell", run: "always" do |s|
#		s.name       = "rex-ray volume map"
#		s.privileged = false
#		s.inline     = "rexray volume ls"
#   	end



    end
  end

end
