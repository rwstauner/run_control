shrc_dir=$HOME/run_control/sh
source $shrc_dir/setup.sh

# Build $PATH.
# Instead of adding /opt/*/bin to $PATH
# consider symlinking those scripts into ~/usr/bin
# to keep the $PATH shorter so less searching is required.

# Homebrew.
source_rc_files $shrc_dir/homebrew.sh

# Personal scripts.
add_to_path $HOME/bin


# Setup terminal first.
source_rc_files $shrc_dir/term.sh

# Get everything else.
source_rc_files $shrc_dir/sh.d/*.sh ~/.shrc.local $EXTRA_SHRC

# Locally compiled, generated, etc.
# Put this after other tools so we can override some things.
add_to_path $HOME/usr/bin

dedupe_path

unset shrc_dir

# Don't let path_helper rearrange the PATH in subshells.
export NO_PATH_HELPER=1
