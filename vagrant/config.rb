# configure() can be run multiple times
Vagrant.configure('2') do |config|

  # Overwrite default ssh port.
  config.vm.network :forwarded_port, {
    :guest        => 22,
    :host         => 3200,
    :host_ip      => '127.0.0.1',
    :id           => 'ssh',
    :auto_correct => true,
  }

  # Confirm that using alternate port range works.
  config.vm.usable_port_range = (3200 .. 3300)

  # Always forward at least one port (so you can use one without restarting)..
  # NOTE: This can cause a suspended vm to not resume when a port conflict
  # is detected.  Resuming the vm in the vbox gui and shutting down fixes it.
  # I think I've only had to do this once for any given suspended vm, but if
  # it happens more often we could try saving the list of used ports somewhere.
  config.vm.network :forwarded_port, {
    :guest        => 3201,
    :host         => 3201,
    :id           => 'vagrant_rc',
    :auto_correct => true,
  }

  # Bridge a network connection without prompting for which NIC:
  #config.vm.network :public_network, :bridge => 'wlan0'

  # customize environment
  rc_dir = File.expand_path("..", __FILE__)
  rc_guest = '/home/vagrant/.vagrant.rc'

  config.vm.synced_folder rc_dir, rc_guest

  config.vm.provision :shell, :inline => <<-SHELL
    for exe in #{rc_guest}/provision/*; do
      test -x "$exe" && echo "$exe" && "$exe"
    done
  SHELL

end
