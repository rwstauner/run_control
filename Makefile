SHELL = /bin/bash

all: apps home
.PHONY: home

GHOSTTY_CONFIG = ~/.config/ghostty/config
GHOSTTY_RC = $(HOME)/run_control/apps/ghostty.conf
GHOSTTY_LINE = "config-file = $(GHOSTTY_RC)"
ghostty:
	mkdir -p $(dir $(GHOSTTY_CONFIG))
	touch $(GHOSTTY_CONFIG)
	diff $(GHOSTTY_CONFIG) <(echo $(GHOSTTY_LINE)) ||:
	echo $(GHOSTTY_LINE) > $(GHOSTTY_CONFIG)

apps: ghostty

links: home
home:
	scripts/home.sh
