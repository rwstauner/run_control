# configure() can be run multiple times
Vagrant.configure('2') do |config|

  # config.vm.provider :virtualbox do |vb|
  #   vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  # end

  # Use VAGRANT_MODIFYVM_* env vars to set vm hardware resources.
  %w[cpus memory].map do |hw|
    key = "VAGRANT_MODIFYVM_#{hw.upcase}"
    ENV[key] ? ["--#{hw}", ENV[key]] : []
  end.flatten.tap do |args|
    config.vm.provider :virtualbox do |vb|
      if not args.empty?
        vb.customize [ "modifyvm", :id, *args ]
      end
    end
  end

  #if true
    # http://tech.shantanugoel.com/2009/07/07/virtualbox-high-cpu-usage-problem-solved.html
    config.vm.provider :virtualbox do |vb|
      vb.customize [
        "modifyvm", :id,
        # Attempt to reduce idle cpu usage: off.
        # More performance, features (64bit): on.
        "--nestedpaging", "on",
        "--ioapic",       "on",
        # "--hwvirtex",   "on",      # VT-x
        # "--vtxvpid" and "--largepages" # Intel
      ]
    end
  #end

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

  config.trigger.before :up do
    Dir[".vagrant/machines/*/virtualbox/id"].each do |vboxfile|
      info "fixing ssh port (#{ vboxfile.split('/')[-3] })"
      cmdprefix = %Q|bash -c 'VBoxManage modifyvm "$(<#{ vboxfile })" --natpf1 %s'|
      run sprintf cmdprefix, %Q|delete ssh|
      run sprintf cmdprefix, %Q|"ssh,tcp,127.0.0.1,#{ 3200 + rand(99) },,22"|
    end
  end

  # Always forward at least one port (so you can use one without restarting).
  # Sadly this does not work well with suspending/resuming.
  # Vagrant doesn't like to change forwarded ports on suspended machines
  # even though the GUI appears to support it.  The GUI also supports
  # changing pf's on running instances so we can just add some when needed.
  if false
    config.vm.network :forwarded_port, {
      :guest        => 3201,
      :host         => 3201,
      :host_ip      => '127.0.0.1',
      :id           => 'vagrant_rc',
      :auto_correct => true,
    }
  end

  if ENV['VAGRANT_NETWORK_BRIDGE']
    # Bridge a network connection without prompting for which NIC:
    config.vm.network :public_network, :bridge => ENV['VAGRANT_NETWORK_BRIDGE']
  end

  # customize environment
  rc_dir = File.expand_path("..", __FILE__)
  rc_guest = '/home/vagrant/.vagrant.rc'

  config.vm.synced_folder rc_dir, rc_guest

  config.vm.provision :shell, :inline => <<-SHELL
    echo '#{ENV['PWD'].match(/[^\/]+$/)[0]}' > /home/vagrant/.vagrant.name
    for exe in #{rc_guest}/provision/*; do
      test -x "$exe" && echo "# rc: $exe" && "$exe"
    done
  SHELL

  if ENV['VAGRANT_GUI']
    config.vm.provider('virtualbox') { |vm| vm.gui = true }
  end

end
