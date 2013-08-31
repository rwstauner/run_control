#!/bin/bash

[[ "`id -nu`" == "vagrant" ]] || exec sudo -Hu vagrant "$0" "$@"

gc='git config --global'

$gc alias.st status
$gc color.ui auto
