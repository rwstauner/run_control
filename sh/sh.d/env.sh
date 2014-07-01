# Environment variables that don't have a better place.

export BROWSER=firefox
export FTP_PASSIVE=1; # used by Net::FTP, and maybe possibly hopefully some other things

#export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/

# Universal file exclusions
export TAR_OPTIONS="$TAR_OPTIONS --exclude-from=$HOME/.excludes"

export XML_CATALOG_FILES="$HOME/devel/xml/catalog /etc/xml/catalog"

if [[ -z "$LS_COLORS" ]]; then
  if which dircolors &> /dev/null; then
    eval `dircolors`
    if [[ -r ~/.dircolors ]]; then
      _def_ls_colors="$LS_COLORS"
      eval `dircolors ~/.dircolors`
      export LS_COLORS="${_def_ls_colors}$LS_COLORS"
      unset _def_ls_colors
    fi
  fi
fi
