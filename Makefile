# fimbul make file for installation
#

MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
WORK_DIR := $(shell dirname ${MKFILE_PATH})
LUA = $(shell which "lua5.3" 2>/dev/null)

ifeq "${LUA}" ""
LUA = $(shell which "lua53")
endif

TESTFOLDER := tests
TESTS := $(wildcard ${TESTFOLDER}/*.lua)
TESTTARGET := $(subst .lua,.test,${TESTS})

PREFIX := /usr

%.test: %.lua
	busted --lua=${LUA} $<

all: install

install:
	@echo "This script is mainly for developers. Please use the proper way"
	@echo "of your distribution to install fimbul. Developers please go"
	@echo "ahead with: sudo make install-dev."

install-dev:
	ln -sf ${WORK_DIR}/bin/fimbul ${PREFIX}/bin/fimbul
	ln -sf ${WORK_DIR}/fimbul ${PREFIX}/share/lua/5.3/fimbul
	ln -sf ${WORK_DIR}/bin ${PREFIX}/lib/fimbul

uninstall-dev:
	rm ${PREFIX}/bin/fimbul || true
	rm ${PREFIX}/share/lua/5.3/fimbul || true
	rm ${PREFIX}/lib/fimbul || true

test: ${TESTTARGET}

help:
	@echo "make [install, install-dev, uninstall-dev, test]"

.PHONY: install install-dev uninstall-dev test
