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

 if ARGV[0] == "up"
   unless `ps alx | grep [v]boxwebsrv` != ""
     printf "starting virtualbox web server\n"
     print `VBoxManage setproperty websrvauthlibrary null && vboxwebsrv -H 0.0.0.0 --background`
   end
 end



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
base_box_version=config['environment']['base_box_version']

engine_version=config['environment']['engine_version']





swarm_master_ip=config['environment']['swarm_masterip']

domain=config['environment']['domain']

boxes = config['boxes']

boxes_hostsfile_entries=""


## EXPERIMENTAL FEATURES

experimental=config['environment']['experimental']

########

## TLS

tls_enabled = config['environment']['tls_enabled']
tls_passphrase = config['environment']['tls_passphrase']

########

## REXRAY

rexray_enabled = config['environment']['rexray_enabled']

# Configuration 
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

########

boxes.each do |box|
  boxes_hostsfile_entries=boxes_hostsfile_entries+box['mgmt_ip'] + ' ' +  box['name'] + ' ' + box['name']+'.'+domain+'\n'
end

#puts boxes_hostsfile_entries

update_hosts = <<SCRIPT
    echo "127.0.0.1 localhost" >/etc/hosts
    echo -e "#{boxes_hostsfile_entries}" |tee -a /etc/hosts
SCRIPT

puts '--------------------------------------------------------------------------------------------'

puts ' Docker SWARM MODE Vagrant Environment'.cyan

puts ' Engine Version: '+engine_version

puts " Experimental Features Enabled" if experimental == true

puts " Engine Secured with TLS (reacheable on 2376 port - vagrant host 5556 if available)" if tls_enabled == true

puts " RexRay Enabled" if rexray_enabled == true

puts '--------------------------------------------------------------------------------------------'

$install_docker_engine = <<SCRIPT
  #curl -sSk $1 | sh
  DEBIAN_FRONTEND=noninteractive apt-get remove -qq docker docker-engine docker.io
  DEBIAN_FRONTEND=noninteractive apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -qq \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | DEBIAN_FRONTEND=noninteractive apt-key add -
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
  DEBIAN_FRONTEND=noninteractive apt-get -qq update
  DEBIAN_FRONTEND=noninteractive apt-get install -y $1
  usermod -aG docker vagrant 2>/dev/null
SCRIPT

$enable_experimental_features = <<SCRIPT
    echo '{"experimental" : true}'> /etc/docker/daemon.json
    systemctl restart docker
SCRIPT


Vagrant.configure(2) do |config|
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  if Vagrant.has_plugin?("vagrant-proxyconf")
    if proxy != ''
        puts " Using proxy"
        config.proxy.http = proxy
        config.proxy.https = proxy
        config.proxy.no_proxy = "localhost,127.0.0.1"
    end
  end
  config.vm.box = base_box
  if base_box_version != ''
  	text="Using "+base_box+" version "+base_box_version
	puts text.red
  	config.vm.box_version = base_box_version
  end
  # case engine_version
  #   when "experimental"
  #       engine_download_url="https://experimental.docker.com"
  #   when "current", "latest", "stable"
  #       engine_download_url="https://get.docker.com"
  #   when "test", "testing", "rc"
  #       engine_download_url="https://test.docker.com"
  #   else
  #       STDERR.puts "Unknown Docker Engine version, please use 'experimental', 'test' or 'stable'".red
  #        exit
  #   end

  case engine_version
  when "latest"
      engine_package="docker-ce"
  else
      engine_package="docker-ce="+engine_version
  end

  text= "Using engine version "+engine_version
  puts text.red

  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
  config.vm.synced_folder "src/", "/src",create:true
  boxes.each do |node|
    config.vm.define node['name'] do |config|
      config.vm.hostname = node['name']
      config.vm.provider "virtualbox" do |v|
        v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]        
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
      config.vm.network "forwarded_port", guest: 8081, host: 8081, auto_correct: true
      config.vm.network "forwarded_port", guest: 8082, host: 8082, auto_correct: true
      config.vm.network "forwarded_port", guest: 8083, host: 8083, auto_correct: true


      config.vm.network "public_network",
      bridge: ["enp4s0","wlp3s0","enp3s0f1","wlp2s0"],
      auto_config: true


      config.vm.provision "shell", inline: <<-SHELL
        apt-get update -qq && apt-get install -qq chrony curl && timedatectl set-timezone Europe/Madrid
      SHELL

      config.vm.provision :shell, :inline => update_hosts

      ## Docker Install
      #puts " Community Engine downloaded from " + engine_download_url

      config.vm.provision "shell" do |s|
       			s.name       = "Install Docker Engine version "+engine_version
        		s.inline     = $install_docker_engine
            s.args       = engine_package
      end

      if experimental == true
        #puts " Experimental Features Enabled"

        config.vm.provision "shell" do |s|
              s.name       = "Experimental Features Enabled on Engine"
              s.inline     = $enable_experimental_features
        end
      end
    
      # config.vm.provision "shell", inline: <<-SHELL
      #     apt-get install -qq curl \
      #     && curl -sSk #{$engine_download_url} | sh \
      #     && usermod -aG docker vagrant 2>/dev/null || true
      # SHELL

      
      if tls_enabled == true

        config.vm.network "forwarded_port", guest: 2376, host: 5556, auto_correct: true

        ## Docker Secure Engine with TLS
        #puts " Engine Secured with TLS (reacheable on 2376 port - vagrant host 5556 if available)"

        config.vm.provision "file", source: "create_tls_certs.sh", destination: "/tmp/create_tls_certs.sh"
        config.vm.provision :shell, :path => 'create_tls_certs.sh' , :args => [ tls_passphrase, node['mgmt_ip'], node['hostonly_ip'], node['name']  ]

      end
    
      ## Create Docker Swarm (Swarm Mode)

      config.vm.provision "file", source: "create_swarm.sh", destination: "/tmp/create_swarm.sh"
      config.vm.provision :shell, :path => 'create_swarm.sh' , :args => [ node['mgmt_ip'], node['swarm_role'], swarm_master_ip, engine_mode ]


      ## Install docker-compose

      config.vm.provision "file", source: "install_compose.sh", destination: "/tmp/install_compose.sh"
      config.vm.provision :shell, :path => 'install_compose.sh'


      if rexray_enabled == true
        config.vm.provision "shell" do |s|
              s.name       = "config rex-ray"
              s.inline     = $write_rexray_config
        end

        # install rex-ray
        config.vm.provision "shell", inline: <<-SHELL
        #curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable 0.9.1
        curl -sSL https://rexray.io/install | sh
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
      end


#	config.vm.provision "shell", run: "always" do |s|
#		s.name       = "rex-ray volume map"
#		s.privileged = false
#		s.inline     = "rexray volume ls"
#   	end


    end
  end

end
