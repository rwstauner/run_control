#!/bin/bash

mkdir -p ~/.ssh/.c

perl -0777 -p -i -e '

  $_ =~ s/\n*^# managed by run_control.+ \{\{\{.+^# \}\}\}\n*//smg;
  $_ .= "

# managed by run_control/'"$0"' {{{
Host *
  Compression yes
  ControlMaster auto
  ControlPath ~/.ssh/.c/%C
  ControlPersist 5m
# }}}
";
  ' ~/.ssh/config
