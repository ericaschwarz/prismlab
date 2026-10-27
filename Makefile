# targets that aren't filenames
.PHONY: all clean deploy build serve

all: build

# Prefer the project-local installation; command-line overrides still work.
ifneq ($(wildcard .venv/Scripts/bibble.exe),)
BIBBLE ?= .venv/Scripts/bibble.exe
else ifneq ($(wildcard .venv/bin/bibble),)
BIBBLE ?= .venv/bin/bibble
else
BIBBLE ?= bibble
endif

.DELETE_ON_ERROR:

_includes/pubs.html: bib/pubs.bib bib/publications.tmpl
	mkdir -p _includes
	$(BIBBLE) $+ > $@

build: _includes/pubs.html
	jekyll build

# you can configure these at the shell, e.g.:
# SERVE_PORT=5001 make serve
SERVE_HOST ?= 127.0.0.1
SERVE_PORT ?= 5000

serve: _includes/pubs.html
	jekyll serve --port $(SERVE_PORT) --host $(SERVE_HOST)

clean:
	$(RM) -r _site _includes/pubs.html

DEPLOY_HOST ?= yourwebpage.com
DEPLOY_PATH ?= www/
RSYNC := rsync --compress --recursive --checksum --itemize-changes --delete -e ssh

deploy: clean build
	$(RSYNC) _site/ $(DEPLOY_HOST):$(DEPLOY_PATH)
