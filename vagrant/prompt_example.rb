Vagrant.configure('2') do |config|

  # Use %q to avoid nested here-doc issue with vim-ruby syntax highlighting.
  config.vm.provision :shell, :inline => %q!
cat <<BASHRC > /home/vagrant/.bashrc.local
# prompt
PS1='\[\033[00;01m \u@\h:\w \033[00m\]\n\$ '
BASHRC

line="source /home/vagrant/.bashrc.local"
file="/home/vagrant/.bashrc"
grep -qFx "$line" "$file" || echo "$line" >> "$file"
  !

end
