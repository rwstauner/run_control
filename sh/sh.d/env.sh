# Environment variables that don't have a better place.

export BROWSER=firefox
export FTP_PASSIVE=1; # used by Net::FTP, and maybe possibly hopefully some other things

#export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/

# Universal file exclusions
export TAR_OPTIONS="$TAR_OPTIONS --exclude-from=$HOME/.excludes"

export XML_CATALOG_FILES="$HOME/devel/xml/catalog /etc/xml/catalog"
