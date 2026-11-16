#!/usr/bin/env bash
# IC102-A Lab 02: put one numbered mistake into your repository.
#
#   ./break.sh N /foss/designs/projects/ttsky-ic102-a      N = 1 to 5
#
# Each breakage is a mistake that a real analog project has made, or one that a
# precheck rule exists to catch. The script changes your working tree and, for
# the layout breakages, rebuilds gds/ and lef/ with `make`. It doesn't commit:
# you commit and push, and the runner tells you what's wrong. The writeup says
# what to write down before you look.
#
# Run it on a clean working tree, so that the commit you make holds exactly one
# breakage and nothing else.
set -euo pipefail

die() { printf 'break.sh: %s\n' "$*" >&2; exit 1; }

[ $# -eq 2 ] || die "usage: ./break.sh N <your repository folder>   (N = 1 to 5)"
N="$1"
[ -d "$2" ] || die "no such folder: $2"
P="$(cd "$2" && pwd)"
[ -f "$P/info.yaml" ] && [ -f "$P/layout/wires.tcl" ] && [ -f "$P/Makefile" ] \
  || die "$P has no info.yaml, layout/wires.tcl or Makefile; finish Lab 01 first"
[ -z "$(git -C "$P" status --porcelain)" ] \
  || die "$P has uncommitted changes; commit or undo them first, so the breakage gets a commit of its own"

cd "$P"
TOP="$(python3 -c 'import yaml; print(yaml.safe_load(open("info.yaml"))["project"]["top_module"])')"

case "$N" in
  1)
    # Every pinout description emptied.
    python3 - <<'EOF'
import re
lines = open("info.yaml").read().split("\n")
out, in_pinout = [], False
for line in lines:
    if line.startswith("pinout:"):
        in_pinout = True
    elif in_pinout and line and not line.startswith(" "):
        in_pinout = False
    if in_pinout:
        line = re.sub(r'^(\s+u[a-z]*\[\d\]:\s*)".*"', r'\1""', line)
    out.append(line)
open("info.yaml", "w").write("\n".join(out))
EOF
    ;;
  2)
    # A stub of metal on ua[2], the next analog pin along.
    printf '%s\n' 'p metal4 113.17 1 114.07 10   ;# ua[2]' >> layout/wires.tcl
    make --no-print-directory
    ;;
  3)
    # The project renamed in info.yaml, the files renamed to match, and the
    # layout not rebuilt.
    NEW="${TOP}_v2"
    sed -i "s/^\(  top_module: *\)\"$TOP\"/\1\"$NEW\"/" info.yaml
    grep -q "\"$NEW\"" info.yaml || die "couldn't find top_module: \"$TOP\" in info.yaml"
    git mv "gds/$TOP.gds" "gds/$NEW.gds"
    git mv "lef/$TOP.lef" "lef/$NEW.lef"
    sed -i "s/^module $TOP\b/module $NEW/" src/project.v
    ;;
  4)
    # A square of metal 5 in an empty corner of the tile.
    printf '%s\n' 'p metal5 20 100 30 110' >> layout/wires.tcl
    make --no-print-directory
    ;;
  5)
    # The second analog supply switched on.
    sed -i 's/^\(  uses_vapwr: *\)false/\1true/' info.yaml
    grep -q '^  uses_vapwr: *true' info.yaml || die "couldn't find uses_vapwr: false in info.yaml"
    ;;
  *)
    die "N must be 1, 2, 3, 4 or 5, not '$N'"
    ;;
esac

echo
echo "Breakage $N is in your working tree:"
git status --short
echo
echo "Commit it and push it:"
echo "  git commit -am \"Lab 02: breakage $N\""
echo "  git push"
