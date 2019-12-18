.DEFAULT_GOAL := all
MAKEFLAGS=--warn-undefined-variables
SHELL := /bin/bash

SUDO ?= $(shell if ! groups | grep -q docker; then echo sudo; fi)

.PHONY: primer
primer:
	wget https://unpkg.com/primer/build/build.css -O _sass/_build.scss

.PHONY: build
build:
	$(SUDO) docker build .

.PHONY: dev
dev:
	$(SUDO) docker build . -f dev.Dockerfile -t personal-website-dev
	$(SUDO) docker run --rm -p 4000:4000 personal-website-dev

.PHONY: all
all: build
