export PAGER=less LESS=FRX

# http://nion.modprobe.de/blog/archives/572-less-colors-for-man-pages.html
# https://linuxtidbits.wordpress.com/2009/03/23/less-colors-for-man-pages/
# Less Colors for Man Pages

# Blinking
export LESS_TERMCAP_mb=$'\E[01;36m'
# Bold
export LESS_TERMCAP_md=$'\E[01;32m'

# End mode
export LESS_TERMCAP_me=$'\E[0m'

# Standout-mode (info box/search highlight)
#export LESS_TERMCAP_so=$'\E[48;5;236;38;5;010m'
#export LESS_TERMCAP_so=$'\E[1;40;34m'
#export LESS_TERMCAP_so=$'\E[1;43;30m'
export LESS_TERMCAP_so=$'\E[1;44m'
export LESS_TERMCAP_se=$'\E[0m'

# Underline
export LESS_TERMCAP_us=$'\E[04;95m'
export LESS_TERMCAP_ue=$'\E[0m'
