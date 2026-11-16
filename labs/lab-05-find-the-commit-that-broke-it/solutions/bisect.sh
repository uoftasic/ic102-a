#!/usr/bin/env bash
# IC102-A Lab 05, reference solution: a script `git bisect run` can trust.
#
# git's rules for the exit status (git help bisect):
#   0        this commit is good
#   1..127   this commit is bad, except
#   125      this commit can't be tested, so skip it
# Anything else, such as the 255 Magic exits with, stops the bisect.
#
# Three things can happen at a commit, and the script has to tell them apart:
#   - there's no GDS, or Magic couldn't read the top cell out of it: can't test (125)
#   - Magic read the layout and found DRC errors: bad (1)
#   - Magic read the layout and found none: good (0)
# Magic's exit status can't tell the first case from the last: when it can't
# find the cell in the GDS, it makes an empty one, checks that, finds nothing
# wrong and exits 0. So the script reads Magic's log and report instead.
LAB=/foss/designs/modules/ic102-a/labs/lab-05-find-the-commit-that-broke-it
OUT=/tmp/lab05-drc

TOP=$(python3 -c 'import yaml; print(yaml.safe_load(open("info.yaml"))["project"]["top_module"])') || exit 125
[ -s "gds/$TOP.gds" ] || exit 125                     # no layout committed here

rm -f "$OUT/magic_drc.txt" "$OUT/magic.log"
"$LAB/magic-drc.sh" "gds/$TOP.gds" "$TOP" "$OUT"      # its exit status is ignored on purpose

grep -q "couldn't be read" "$OUT/magic.log" && exit 125     # Magic checked an empty cell
grep -q "Error while reading" "$OUT/magic.log" && exit 125  # the GDS is cut short
COUNT=$(sed -n 's/^\[INFO\]: COUNT: //p' "$OUT/magic_drc.txt" 2>/dev/null)
[ -n "$COUNT" ] || exit 125                           # Magic stopped before its report

[ "$COUNT" -eq 0 ] && exit 0
exit 1
