#!/bin/bash

function ensure_line () {
  line="$1" file="$2"
  grep -qFx "$line" "$file" || echo "$line" >> "$file"
}

ensure_line "$(cat ~/run_control/vagrant/loader.rb)" ~/.vagrant.d/Vagrantfile
