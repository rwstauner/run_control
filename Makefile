SHELL=/bin/bash
DIFF = git diff --no-index

# everything but . and ..
ALL_RC_FILES = $(wildcard .[^.]*)
# files to copy instead of link (files include additional instructions
CP_RC_FILES = .gitconfig
# files I'm not using anymore
ARCHIVED_RC = .pork .ratpoisonrc
# files that don't need to go anywhere
EXCLUDE_RC = $(ARCHIVED_RC) $(wildcard .*.css) .git $(wildcard .screenrc.*)
# everything else
LN_RC_FILES = $(filter-out $(CP_RC_FILES) $(EXCLUDE_RC),$(ALL_RC_FILES))

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
			[[ -e "$$dest" ]] && ! [[ -s "$$dest" ]] && filedesc="empty"; \
			echo "  skipping pre-existing $$filedesc file: $$dest"; \
		fi; \
	else \
		echo ln -s "$$source" "$$dest"; \
	fi
endef

define EXISTS_OR
	source="$(SOURCEDIR)/$(1)"; \
	dest="$(HOME)/$(2)"; \
	ifexists='$(3)'; \
	notexists='$(4)'; \
	if [ -e "$$dest" ]; then \
		case "$$ifexists" in \
			w) echo -e "  \033[01;41m file exists: $$dest \033[00m " 1>&2;; \
			d) $(DIFF) "$$source" "$$dest";; \
		esac; \
	else \
		case "$$notexists" in \
			c) /bin/cp -vin "$$source" "$$dest";; \
			e) echo " == '$$dest' does not exist == ";; \
		esac; \
	fi
endef

all:
	@if [ "`pwd`" != "$(SOURCEDIR)" ]; then \
		echo "link to $(SOURCEDIR) and try again"; \
		exit 1; \
	fi; \
	for rc in $(LN_RC_FILES); do \
		$(call LINK_RC,$$rc,$$rc); \
	done; \
	host=`hostname -s`; \
	scrloc=.screenrc.$$host; \
	if [ -e $$scrloc ]; then \
		$(call LINK_RC,$$scrloc,.screenrc.local); \
	else \
		touch $(HOME)/.screenrc.local; \
	fi; \
	for rc in $(CP_RC_FILES); do \
		$(call EXISTS_OR,$$rc,$$rc,w,c); \
	done;
	@echo -e "\033[0044mTODO:\033[00m dzil"

diff:
	@for rc in $(CP_RC_FILES); do \
		$(call EXISTS_OR,$$rc,$$rc,d,e); \
	done;
