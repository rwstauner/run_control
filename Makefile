SHELL=/bin/bash
DIFF = git diff --no-index

# everything but . and ..
ALL_RC_FILES = $(shell ls -A home/)

# files that don't need to go anywhere
EXCLUDE_RC = $(subst home/,,$(wildcard home/.tmux.conf.*))
# everything else
LN_RC_FILES = $(filter-out $(EXCLUDE_RC),$(ALL_RC_FILES))

DIRNAME = run_control
SOURCEDIR = $(HOME)/$(DIRNAME)

define LINK_RC
	source="$(DIRNAME)/home/$(1)"; \
	dest="$(HOME)/$(2)"; \
	if [ -e "$$dest" ]; then \
		if [ "`readlink "$$dest"`" == "$$source" ]; then \
			echo -e " \033[33m already linked: $$dest \033[00m " 1>&2; \
		else \
			[[ -e "$$dest" ]] && ! [[ -s "$$dest" ]] && filedesc="empty"; \
			echo "  skipping pre-existing $$filedesc file: $$dest"; \
		fi; \
	else \
		if [[ -h "$$dest" ]]; then \
			echo "removing broken symlink $$dest (`readlink $$dest`)"; \
			rm -vf "$$dest"; \
		fi; \
		echo ln -s "$$source" "$$dest"; \
		ln -s "$$source" "$$dest"; \
	fi
endef

.PHONY: all in_home links scripts

# NOTE: $(call X,$$shvar) needs doubled $'s ($$$$shvar) in older make
all:

links: in_home
	for rc in $(LN_RC_FILES); do \
		$(call LINK_RC,$$rc,$$rc); \
	done; \
	host=`hostname -s`; \
	termloc=.tmux.conf.$$host; \
	if [ -e $$termloc ]; then \
		$(call LINK_RC,$$termloc,.tmux.conf.local); \
	else \
		touch $(HOME)/.tmux.conf.local; \
	fi;
	@echo -e "\033[0044mTODO:\033[00m dzil"

in_home:
	@if [ "`pwd`" != "$(SOURCEDIR)" ]; then \
		echo "link to $(SOURCEDIR) and try again"; \
		exit 1; \
	fi;

scripts: in_home
	@umask 0077; \
	for script in scripts/*; do echo $$script; ./$$script; done
