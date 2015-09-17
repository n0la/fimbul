# fimbul make file for installation
#

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
work_dir := $(shell dirname ${mkfile_path})

all: install

install:
	@echo "This script is mainly for developers. Please use the proper way"
	@echo "of your distribution to install fimbul. Developers please go"
	@echo "ahead with: sudo make install-dev."

install-dev:
	ln -sf ${work_dir}/bin/fimbul /usr/bin/fimbul
	ln -sf ${work_dir}/bin/dice /usr/bin/dice
	ln -sf ${work_dir}/fimbul /usr/share/lua/5.2/fimbul
	ln -sf ${work_dir}/bin /usr/lib/fimbul

uninstall-dev:
	rm /usr/bin/fimbul || true
	rm /usr/bin/dice || true
	rm /usr/share/lua/5.2/fimbul || true
	rm /usr/lib/fimbul || true

help:
	@echo "make [install, install-dev, uninstall-dev]"

.PHONY: install install-dev uninstall-dev
