rc_dir=$HOME/run_control

zshrc_dir=$rc_dir/zsh

# Load OMZ first so that we can overwrite.
source $zshrc_dir/ohmy.zsh

source $rc_dir/sh/loader.sh

# Load everything else.
source_rc_files $zshrc_dir/zsh.d/* ~/.zshrc.local $EXTRA_ZSHRC

unset rc_dir zshrc_dir
