rc_dir=$HOME/run_control

zshrc_dir=$rc_dir/zsh

# Load OMZ first so that we can overwrite.
# If OMZ fails it won't load our theme, so load prompt explicitly.
source $zshrc_dir/ohmy.zsh \
  source $zshrc_dir/prompt.zsh

# See https://github.com/zsh-users for more handy utilities.

source $rc_dir/sh/loader.sh

# Load everything else.
source_rc_files $zshrc_dir/zsh.d/* ~/.zshrc.local $EXTRA_ZSHRC

unset rc_dir zshrc_dir
