.PHONY: install uninstall update lint test help

help:
	@echo "living-docs — available targets:"
	@echo ""
	@echo "  make install    install plugin to ~/.claude/plugins/living-docs"
	@echo "  make uninstall  remove plugin"
	@echo "  make update     pull latest changes"
	@echo "  make lint       shellcheck + JSON validation"
	@echo "  make test       lint + plugin structure validation"

install:
	./scripts/install.sh

uninstall:
	./scripts/uninstall.sh

update:
	./scripts/update.sh

lint:
	@echo "--- shellcheck ---"
	shellcheck hooks/*.sh scripts/*.sh
	@echo "--- JSON ---"
	python3 -c "import json; json.load(open('manifest.json')); print('manifest.json OK')"
	python3 -c "import json; json.load(open('.living-docs.example.json')); print('.living-docs.example.json OK')"

test: lint
	@echo "--- plugin structure ---"
	@python3 -c "\
import json, os, sys; \
m = json.load(open('manifest.json')); \
missing = [f for f in m.get('skills',[]) + m.get('subagents',[]) + list(m.get('hooks',{}).values()) if not os.path.exists(f)]; \
(print('Missing files:', missing) or sys.exit(1)) if missing else print('All files present.') \
"
	@echo "--- skill frontmatter ---"
	@python3 -c "\
import os, sys; \
errors = []; \
[errors.append(f'{r}/{f}: missing frontmatter') \
  for r,_,fs in os.walk('skills') for f in fs \
  if f.endswith('.md') and not open(os.path.join(r,f)).read().startswith('---')]; \
(print('\n'.join(errors)) or sys.exit(1)) if errors else print('Frontmatter OK.') \
"
	@echo "All checks passed."
