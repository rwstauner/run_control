export PYTHONSTARTUP=$HOME/.python_startup

alias json_tool='python -m json.tool'

export VIRTUAL_ENV_DISABLE_PROMPT=1
source_rc_files ~/python/venv/local/bin/activate

function tox () {
  # Prepend any local python builds to the path so tox can access them.
  PATH=`python -c 'import sys; print ":".join(sys.argv[1:])' \
    $(ls -d ~/python/p/*/bin) "$PATH"` command tox "$@"
}
