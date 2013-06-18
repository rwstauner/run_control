export PYTHONSTARTUP=$HOME/python/rc/startup.py

alias json_tool='python -m json.tool'

export VIRTUAL_ENV_DISABLE_PROMPT=1
source_rc_files ~/python/venv/local/bin/activate

function tox () {
  # Prepend any local python builds to the path so tox can access them.
  PATH=`python -c 'import sys; print ":".join(sys.argv[1:])' \
    $(ls -d ~/python/p/*/bin) "$PATH"` command tox "$@"
}

function pip () {
  if ! [[ -d "$VIRTUAL_ENV" ]]; then
    echo $' \033[01;33m WARNING:\033[00m Python virtualenv is not active.\n'
  fi
  command pip "$@"
}
