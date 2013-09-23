export PYTHONSTARTUP=$HOME/python/rc/startup.py

export PIP_DOWNLOAD_CACHE=$HOME/python/pip-downloads

[[ -f ~/bin/contrib/json_tool ]] || alias json_tool='python -m json.tool'

export VIRTUAL_ENV_DISABLE_PROMPT=1
source_rc_files ~/python/venv/local/bin/activate

_python_logo="$HOME/data/images/tech/python_logo_transparent.png"
test -f $_python_logo || _python_logo=/usr/share/pixmaps/python.xpm

function nosetests () {
  command nosetests "$@"
  notify_result -i "$_python_logo"
}

function tox () {
  # Prepend any local python builds to the path so tox can access them.
  PATH=`python -c 'import sys; print ":".join(sys.argv[1:])' \
    $(ls -d ~/python/p/*/bin) "$PATH"` command tox "$@"
  notify_result -i "$_python_logo"
}

function pip () {
  if ! [[ -d "$VIRTUAL_ENV" ]]; then
    echo $' \033[01;33m WARNING:\033[00m Python virtualenv is not active.\n'
  fi
  command pip "$@"
}

function vim_py () {
  local py="${1//\.//}"
  local pyfile=''
  pypath=($(python -c 'import sys; print "\n".join(sys.path)'))
  for dir in "${pypath[@]}"; {
    for pyfile in "$dir/$py.py" "$dir/$py/__init__.py"; {
      [[ -f "$pyfile" ]] && break
    }
    [[ -f "$pyfile" ]] && break
  }
  if [[ -f "$pyfile" ]]; then
    vim "$pyfile";
  else
    echo "Not found: $py"
    return 1
  fi
}
