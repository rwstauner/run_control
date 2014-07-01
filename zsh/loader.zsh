rc_dir=$HOME/run_control

source $rc_dir/sh/loader.sh

zshrc_dir=$HOME/run_control/zsh
source_rc_files $zshrc_dir/zsh.d/* ~/.zshrc.local $EXTRA_ZSHRC

# OMZ criples my LESS options so restore them.
source $rc_dir/sh/sh.d/less.sh

unset rc_dir zshrc_dir
