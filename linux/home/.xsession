#!/bin/bash

xset b off # shh!
xmodmap ~/.xmodmaprc & disown

~/run_control/linux/bin/configure-touchpad
