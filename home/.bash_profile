# .bash_profile

umask 022

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs

export BROWSER=firefox
export FTP_PASSIVE=1; # used by Net::FTP, and maybe possibly hopefully some other things

export PAGER=less LESS=FRX

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/
export XML_CATALOG_FILES="$HOME/devel/xml/catalog /etc/xml/catalog"
