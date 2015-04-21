#!/bin/bash

umask 0077
bin=$HOME/usr/bin

function ensure_line () {
  line="$1" file="$2"
  grep -qFx "$line" "$file" || echo "$line" >> "$file"
}

test -d ~/.vagrant.d && \
ensure_line "$(cat ~/run_control/vagrant/loader.rb)" ~/.vagrant.d/Vagrantfile

# TODO: /opt/vagrant/bin/* ?
# At that point it's probably better to just put it back in $PATH.

for script in vagrant; do
  ln -sf /opt/vagrant/bin/$script $bin/$script
done

plugin () {
  vagrant plugin list | grep -F "$1" || \
  vagrant plugin install "$@"
}

if which vagrant &> /dev/null; then

  # Make .env available in Vagrantfile.
  plugin vagrant-env

  # Make guest notify-send propagate to host.
  plugin vagrant-notify

  # Add functionality to vagrant commands/events.
  plugin vagrant-triggers

  # Auto-install virtualbox guest additions.
  plugin vagrant-vbguest

fi

# TODO: test -e $bin/packer || unzip
