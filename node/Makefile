GEN_CONF = package.json
DO_GEN_CONF = python -c 'import json, yaml, sys; print(json.dumps(yaml.safe_load(sys.stdin), indent=2))' < package.yaml

all: $(GEN_CONF)

.PHONY: install
install: $(GEN_CONF)
	npm install -g

.PHONY: diff
diff:
	@$(DO_GEN_CONF) | diff $(GEN_CONF) -

.PHONY: $(GEN_CONF)
$(GEN_CONF):
	$(DO_GEN_CONF) > $(GEN_CONF)
