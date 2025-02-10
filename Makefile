SHELL = /bin/bash

all: apps links

GHOSTTY_CONFIG = ~/.config/ghostty/config
GHOSTTY_RC = ~/run_control/apps/ghostty.conf
GHOSTTY_LINE = "config-file = $(GHOSTTY_RC)"
ghostty:
	touch $(GHOSTTY_CONFIG)
	diff $(GHOSTTY_CONFIG) <(echo $(GHOSTTY_LINE)) ||:
	echo $(GHOSTTY_LINE) > $(GHOSTTY_CONFIG)

apps: ghostty

links:
	scripts/home.sh
