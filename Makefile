# fimbul make file for installation
#

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
WORK_DIR := $(shell dirname ${MKFILE_PATH})
LUA = $(shell which "lua5.2")

TESTFOLDER := tests
TESTS := $(wildcard ${TESTFOLDER}/*.lua)
TESTTARGET := $(subst .lua,.test,${TESTS})

%.test: %.lua
	busted --lua=${LUA} $<

all: install

install:
	@echo "This script is mainly for developers. Please use the proper way"
	@echo "of your distribution to install fimbul. Developers please go"
	@echo "ahead with: sudo make install-dev."

install-dev:
	ln -sf ${WORK_DIR}/bin/fimbul /usr/bin/fimbul
	ln -sf ${WORK_DIR}/bin/dice /usr/bin/dice
	ln -sf ${WORK_DIR}/fimbul /usr/share/lua/5.2/fimbul
	ln -sf ${WORK_DIR}/bin /usr/lib/fimbul

uninstall-dev:
	rm /usr/bin/fimbul || true
	rm /usr/bin/dice || true
	rm /usr/share/lua/5.2/fimbul || true
	rm /usr/lib/fimbul || true

test: ${TESTTARGET}

help:
	@echo "make [install, install-dev, uninstall-dev, test]"

.PHONY: install install-dev uninstall-dev test
