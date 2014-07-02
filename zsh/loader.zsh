rc_dir=$HOME/run_control

source $rc_dir/sh/loader.sh

zshrc_dir=$HOME/run_control/zsh

# Load OMZ first so that we can overwrite.
source_rc_files $zshrc_dir/ohmy.zsh

# OMZ criples my LESS options so restore them.
source $rc_dir/sh/sh.d/less.sh

# Load everything else.
source_rc_files $zshrc_dir/zsh.d/* ~/.zshrc.local $EXTRA_ZSHRC

unset rc_dir zshrc_dir
