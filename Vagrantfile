VAGRANTFILE_API_VERSION = "2"

require 'yaml'

################################################################################
# check plugins
################################################################################
plugins = ["vagrant-hostmanager", "vagrant-vbguest"]
plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    raise plugin << " has not been installed."
  end
end

################################################################################
# read YAML file with server and box details
################################################################################
server = YAML.load_file('config/servers.yaml')

################################################################################
# define r10k run
################################################################################
R10K = "r10k deploy environment -c /etc/puppet/r10k.yaml -pv"

################################################################################
# define puppet apply
################################################################################
default_env = 'production'
ext_env     = ENV['VAGRANT_PUPPET_ENV']
env         = ext_env ? ext_env : default_env
PUPPETAPPLY = "puppet apply --verbose --hiera_config /etc/puppet/hiera.yaml --modulepath=/etc/puppet/environments/#{env}/modules /vagrant/puppet/manifests/default.pp"

################################################################################
# start vm build
################################################################################
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  ##############################################################################
  # Change hosts file, both on clients and host
  ##############################################################################
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define server["name"] do |srv|
    config.vm.hostname                = server["hostname"]
    srv.vm.box                        = "../../boxes/" << server["box"]
    srv.vm.provider :virtualbox do |vb|
      vb.name   = server["name"]
      vb.memory = server["ram"]
    end
    srv.vm.network "private_network", ip: server["ip"]

    if server["ports"]
      server["ports"].each do |port|
        srv.vm.network "forwarded_port", guest_ip: server["ip"], guest: port["guest"], host: port["host"]
      end
    end

    # Configure cached packages to be shared between instances of the same base box.
    if Vagrant.has_plugin?("vagrant-cachier")
      config.cache.scope = :machine
      config.cache.auto_detect = false
      config.cache.enable :apt
      config.cache.enable :gem
      config.cache.synced_folder_opts = {
        type: :nfs,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      }
    end

    if server["synced_folders"]
      server["synced_folders"].each do |folder|
        srv.vm.synced_folder folder["src"], folder["dst"]
      end
    end

    srv.vm.provision :hosts
    # update repo
    srv.vm.provision :shell, :inline => <<-SHELL
      wget https://apt.puppetlabs.com/puppetlabs-release-pc1-wheezy.deb
      sudo apt-get -y install puppetlabs-release-pc1-wheezy.deb
      sudo apt-get update
    SHELL

    # we could move this to the base box, so loading will be faster
    srv.vm.provision :shell, :inline => <<-SHELL
      apt-get update --fix-missing
      # prepare puppetmaster environment
      test -d /etc/puppet || mkdir /etc/puppet
      cp /vagrant/files/autosign.conf /etc/puppet
      cp /vagrant/files/hiera.yaml /etc/puppet
      cp /vagrant/files/r10k.yaml /etc/puppet
      # add ssh keys for accessing git server
      test -d ~/.ssh || cp -rf /vagrant/files/.ssh ~
      chmod 600 ~/.ssh/id_rsa
    SHELL

    # install R10K
    srv.vm.provision :puppet do |puppet|
      puppet.working_directory = "/vagrant/puppet"
      puppet.module_path       = "puppet/modules"
      puppet.manifests_path    = "puppet/manifests"
      puppet.manifest_file     = "r10k.pp"
      puppet.hiera_config_path = "puppet/hiera.yaml"
      puppet.options           = "--debug --verbose --environment #{env}"
    end
    srv.vm.provision :shell, inline: "echo Starting R10K"
    srv.vm.provision :shell, inline: R10K

    srv.vm.provision :shell, inline: "echo Starting puppet apply"
    srv.vm.provision :shell, inline:  PUPPETAPPLY
  end
end
