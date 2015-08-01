export PYTHONSTARTUP=$HOME/python/rc/startup.py

export PIP_DOWNLOAD_CACHE=$HOME/python/pip-downloads

#export PYTHONDOCS=http://localhost/docs/python-2.7.4-docs-html/
export DJANGO_COLORS='dark'

[[ -f ~/usr/bin/json.tool ]] || alias json.tool='python -m json.tool'

export VIRTUAL_ENV_DISABLE_PROMPT=1

_py_venv=$HOME/python/venv/local/bin/activate
test -r $_py_venv && source $_py_venv
unset _py_venv

_python_logo="$HOME/data/images/tech/python_logo_transparent.png"
test -f $_python_logo || _python_logo=/usr/share/pixmaps/python.xpm

nosetests () {
  command nosetests "$@"
  notify_result -i "$_python_logo"
}

tox () {
  # Prepend any local python builds to the path so tox can access them.
  PATH=`python -c 'import sys; print ":".join(sys.argv[1:])' \
    $(ls -d ~/python/p/*/bin) "$PATH"` command tox "$@"
  notify_result -i "$_python_logo"
}

pip () {
  if ! [[ -d "$VIRTUAL_ENV" ]]; then
    echo $' \033[01;33m WARNING:\033[00m Python virtualenv is not active.\n'
  fi
  command pip "$@"
}

vim_py () {
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
