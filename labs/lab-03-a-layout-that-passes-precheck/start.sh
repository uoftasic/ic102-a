#!/usr/bin/env bash
# IC102-A Lab 03: add the inverter, its wiring and an LVS reference to your
# repository.
#
#   ./start.sh /foss/designs/projects/ttsky-ic102-a
#
# Copies into your repository's layout/ folder:
#   cells/ic102_inv.mag      the inverter from AD104 Lab 03, DRC and LVS clean
#   wires.tcl                replaces Lab 01's two stubs: the inverter placed and
#                            wired, except for one wire, which you draw
#   lvs/reference.spice      the circuit the finished layout should contain,
#                            with your top_module filled in
# Lab 01's layout kit has to be there already. It never overwrites a cell or a
# reference that exists. The old wires.tcl, with Lab 01's stubs, is still in
# your last commit: `git diff layout/wires.tcl` shows what changed.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
die() { printf 'start.sh: %s\n' "$*" >&2; exit 1; }

[ $# -eq 1 ] || die "usage: ./start.sh <your repository folder>"
[ -d "$1" ] || die "no such folder: $1"
P="$(cd "$1" && pwd)"
[ -f "$P/info.yaml" ] && [ -f "$P/layout/build.tcl" ] && [ -f "$P/Makefile" ] \
  || die "$P doesn't have Lab 01's layout kit (layout/build.tcl and Makefile); finish Lab 01 first"
[ ! -e "$P/layout/cells/ic102_inv.mag" ] || die "$P/layout/cells/ic102_inv.mag already exists; nothing copied"
[ ! -e "$P/layout/lvs/reference.spice" ] || die "$P/layout/lvs/reference.spice already exists; nothing copied"
grep -q '^tieoff' "$P/layout/wires.tcl" && die "$P/layout/wires.tcl already has Lab 03's wiring; nothing copied"

TOP="$(python3 -c 'import sys, yaml; print(yaml.safe_load(open(sys.argv[1]))["project"]["top_module"])' "$P/info.yaml")"

mkdir -p "$P/layout/cells" "$P/layout/lvs"
cp "$HERE/cells/ic102_inv.mag" "$P/layout/cells/"
sed "s/@TOP@/$TOP/g" "$HERE/kit/reference.spice" > "$P/layout/lvs/reference.spice"
cp "$HERE/kit/wires.tcl" "$P/layout/wires.tcl"

echo "Added the inverter and its wiring to $P/layout:"
git -C "$P" status --short
