#!/bin/bash

rc=$HOME/run_control
kb=$rc/keyboard

custom-keys () {
  $rc/keyboard/format-compose
}

generate () {
  dest="$1"
  mkdir -p "${dest%/*}"
  cat > "$dest"
}

indent () {
  perl -pe 'print "  " if /\S/'
}

generated="generated by $0 at $(date)"

if [[ `uname` == Darwin ]]; then

  mac=$rc/mac
  compose=$HOME/.cache/Compose.txt
  [[ -e "$compose" ]] || \
    curl -s https://r4s6.net/Compose.txt | generate "$compose"

  {
    echo "/* $generated */"
    echo '{'
    cat $mac/key-bindings.dict | indent

    # http://xahlee.info/kbd/osx_keybinding_key_syntax.html
    echo '  /* Compose Key: F19 */'
    echo -n '  "\UF716" = '
    # echo '  /* Compose Key: F12 */'
    # echo -n '  "\UF70F" = '

    {
      # Custom first (first in wins).
      custom-keys
      cat $compose
    } | $mac/compose2keybindings.pl | indent
    echo '}'
  } | generate ~/Library/KeyBindings/DefaultKeyBinding.dict

  {
    perl -ne 'next unless /^"(.+?)" "(.+?)"(?: # (.+))$/; print qq[";$1","$2","$3"\n];' $rc/keyboard/compose.txt
  } | generate ~/tmp/text-expander-compose-key.csv

else

  {
    echo "# $generated"
    echo 'include "%L"'
    custom-keys
  } | generate ~/.XCompose

fi
