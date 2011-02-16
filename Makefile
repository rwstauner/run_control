SHELL=/bin/bash

# everything but . and ..
ALL_RC_FILES = $(wildcard .[^.]*)
# files I'm not using anymore
EXCLUDE_RC = $(wildcard .*.css) .git .pork .ratpoisonrc $(wildcard .screenrc.*)
RC_FILES = $(filter-out $(EXCLUDE_RC),$(ALL_RC_FILES))

DIRNAME = run_control
SOURCEDIR = $(HOME)/$(DIRNAME)

# TODO: use readlink to compare
define LINK_RC
	source="$(DIRNAME)/$(1)"; \
	dest="$(HOME)/$(2)"; \
	if [ -e "$$dest" ]; then \
		if [ "`readlink "$$dest"`" == "$$source" ]; then \
			echo -e " \033[33m already linked: $$dest \033[00m " 1>&2; \
		else \
			echo "  skipping pre-existing file: $$dest"; \
		fi; \
	else \
		echo ln -s "$$source" "$$dest"; \
	fi
endef

all:
	@if [ "`pwd`" != "$(SOURCEDIR)" ]; then \
		echo "link to $(SOURCEDIR) and try again"; \
		exit 1; \
	fi; \
	for rc in $(RC_FILES); do \
		$(call LINK_RC,$$rc,$$rc); \
	done; \
	host=`hostname -s`; \
	scrloc=.screenrc.$$host; \
	if [ -e $$scrloc ]; then \
		$(call LINK_RC,$$scrloc,.screenrc.local); \
	else \
		touch $(HOME)/.screenrc.local; \
	fi
	@echo -e "\033[0044mTODO:\033[00m dzil"
