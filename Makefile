HUGO ?= hugo

.PHONY: post serve build check test

## make post SLUG=my-post-slug — scaffold the EN+PT pair with a shared translationKey
post:
ifndef SLUG
	$(error Usage: make post SLUG=my-post-slug)
endif
	$(HUGO) new content/en/writing/$(SLUG).md
	$(HUGO) new content/pt/artigos/$(SLUG).md
	@echo "Created EN+PT pair for '$(SLUG)'. Write both, set draft: false on both, push."

## Live preview including drafts
serve:
	$(HUGO) server -D

## Production build (what CI runs)
build:
	$(HUGO) --minify --gc

## Full local gate: build + translation mirror
check: build
	python3 scripts/check_translations.py content

## Run the script test suite
test:
	./tests/check_translations_test.sh
