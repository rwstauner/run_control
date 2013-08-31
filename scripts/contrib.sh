#!/bin/bash

bin="$HOME/bin/contrib"
completion="$HOME/.bashrc.d/completion.d/contrib"
mkdir -p "$bin" "$completion"

if uname -m -i -p | sed 's/ /\n/g' | uniq | grep -q x86_64; then
  bit=64
else
  bit=32
fi

function dl () {
  dest="$1" url="$2"
  test -s "$dest" || wget "$url" -O "$dest"
}

function dl_bin () {
  dest="$bin/$1"
  dl "$dest" "$2"
  chmod 0755 "$dest"
}

function dl_cmp () {
  dl "$completion/$1.bashrc" "$2"
}

dzil_repo_comp=$HOME/data/builds/github/dist-zilla/misc/dzil-bash_completion
if [[ -e $dzil_repo_comp ]]; then
  ln -s $dzil_repo_comp $completion/dzil.bashrc
else
  dl_cmp dzil https://github.com/rjbs/dist-zilla/raw/master/misc/dzil-bash_completion
fi

dl_cmp  vagrant   https://github.com/mitchellh/vagrant/raw/master/contrib/bash/completion.sh
dl_cmp  django    https://github.com/django/django/raw/master/extras/django_bash_completion

dl_bin  diff-highlight  https://github.com/git/git/raw/master/contrib/diff-highlight/diff-highlight
dl_bin  es      http://download.elasticsearch.org/es2unix/es
dl_bin  jq      http://stedolan.github.io/jq/download/linux${bit}/jq
dl_bin  hub     http://defunkt.io/hub/standalone
dl_bin  viack   https://github.com/tsibley/viack/raw/master/viack

# python

pipc="$completion/pip.bashrc"
test -s "$pipc" || pip completion --bash > "$pipc"

json_tool="$bin/json_tool"
if ! [[ -f "$json_tool" ]]; then
  # Use pydoc to find the file.
  jtpy="`pydoc json.tool | awk '{ if( found ){ print $1; exit } } /FILE/ { found=1 }'`"
  if [[ -f "$jtpy" ]]; then
    # Insert a shebang and change the indent level.
    sed -e '1 i #!/usr/bin/env python' -e 's/indent=4/indent=2/' "$jtpy" > "$json_tool"
    # Set exec bit.
    chmod 0755 "$json_tool"
  fi
fi
