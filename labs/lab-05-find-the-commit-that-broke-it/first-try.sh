#!/usr/bin/env bash
# IC102-A Lab 05: a first try at a script for `git bisect run`.
#
# git runs it at each commit it checks out, from the top of the repository, and
# reads the commit's verdict from its exit status. This one hands git whatever
# Magic's DRC script exits with. Read it, then predict what git will make of it
# (Part 3 of the lab), before you run it.
LAB=/foss/designs/modules/ic102-a/labs/lab-05-find-the-commit-that-broke-it

TOP=$(python3 -c 'import yaml; print(yaml.safe_load(open("info.yaml"))["project"]["top_module"])')
"$LAB/magic-drc.sh" "gds/$TOP.gds" "$TOP" /tmp/lab05-drc
