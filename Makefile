.DEFAULT_GOAL := all
MAKEFLAGS=--warn-undefined-variables
SHELL := /bin/bash

SUDO ?= $(shell if ! groups | grep -q docker; then echo 'sudo --preserve-env=DOCKER_BUILDKIT'; fi)

.PHONY: primer
primer:
	wget https://cdnjs.cloudflare.com/ajax/libs/Primer/14.3.0/primer.min.css -O _sass/_build.scss

.ONESHELL: submodules
.PHONY: submodules
submodules:
	cd _useful-links
	git pull

_posts/2019-12-18-useful-links.md: _posts/_2019-12-18-useful-links.md _useful-links/README.md
	cat _posts/_2019-12-18-useful-links.md >$@
	tail _useful-links/README.md -n +5 >>$@

.PHONY: update
update: submodules _posts/2019-12-18-useful-links.md primer

.PHONY: build
build: _posts/2019-12-18-useful-links.md
	$(SUDO) docker build . --pull --build-arg JEKYLL_GITHUB_TOKEN

.PHONY: dev
dev: _posts/2019-12-18-useful-links.md
	$(SUDO) docker build . --pull -f dev.Dockerfile -t personal-website-dev --build-arg JEKYLL_GITHUB_TOKEN
	$(SUDO) docker run --rm -p 4000:4000 personal-website-dev

.PHONY: all
all: build
