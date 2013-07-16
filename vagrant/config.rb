# configure() can be run multiple times
Vagrant.configure('2') do |config|

  # Overwrite default ssh port.
  config.vm.network :forwarded_port, {
    :guest        => 22,
    :host         => 3199,
    :host_ip      => '127.0.0.1',
    :id           => 'ssh',
    :auto_correct => true,
  }

  # Confirm that using alternate port range works.
  config.vm.usable_port_range = (3200 .. 3250)


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
