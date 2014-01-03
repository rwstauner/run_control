#!/bin/bash

umask 0077
bin=$HOME/bin/contrib

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

# TODO: test -e $bin/packer || unzip
