# IC102-A: Tiny Tapeout's precheck tools, at the versions precheck uses.
#
#   make install                   install everything into .local/
#   make check-tools               each tool: runner's version, here, workbench
#   make precheck PROJECT=<dir>    run precheck on your repository
#   make help                      every target

PROJECT ?=
SHELL := /bin/bash

.PHONY: help install check-tools precheck precheck-workbench selftest uninstall

help:
	@echo "make install                      install the pinned tools into .local/ (about 3 GB)"
	@echo "make check-tools                  print each version next to the pinned one"
	@echo "make precheck PROJECT=<dir>       Tiny Tapeout's precheck on <dir>, with the pinned tools"
	@echo "make precheck-workbench PROJECT=<dir>"
	@echo "                                  the same checks with the workbench's Magic, KLayout and PDK"
	@echo "make selftest                     precheck on the analog template's empty 1x2 frame"
	@echo "make uninstall                    delete .local/"

install:
	./install.sh

check-tools:
	@./check-tools.sh

precheck:
	@[ -n "$(PROJECT)" ] || { echo "usage: make precheck PROJECT=<your repository folder>"; exit 2; }
	./precheck.sh "$(PROJECT)"

precheck-workbench:
	@[ -n "$(PROJECT)" ] || { echo "usage: make precheck-workbench PROJECT=<your repository folder>"; exit 2; }
	TT_TOOLSET=workbench ./precheck.sh "$(PROJECT)"

selftest:
	./selftest.sh

uninstall:
	rm -rf .local
