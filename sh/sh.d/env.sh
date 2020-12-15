# Environment variables that don't have a better place.

export BROWSER=firefox
export FTP_PASSIVE=1; # used by Net::FTP, and maybe possibly hopefully some other things

#export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/:/usr/lib/pkgconfig/

# SC1090: Can't follow non-constant source. Use a directive to specify lo⦉cation.
# SC2006: Use $(...) notation instead of legacy backticked `...`.
# SC2164: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
# SC2155: Declare and assign separately to avoid masking return values.
export SHELLCHECK_OPTS="-e SC2006 -e SC2164 -e SC2155"

# Universal file exclusions
export TAR_OPTIONS="$TAR_OPTIONS --exclude-from=$HOME/.excludes"

# Don't load mac crap for Apple_Terminal
unset TERM_PROGRAM

export XML_CATALOG_FILES="$HOME/devel/xml/catalog /etc/xml/catalog"
