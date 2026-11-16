#!/usr/bin/env bash
# IC102-A Lab 01: add the course's layout kit to your repository.
#
#   ./start.sh /foss/designs/projects/ttsky-ic102-a
#
# Copies into your repository:
#   Makefile              make, make docs, make precheck, make drc, make lvs, make view
#   layout/init.tcl       Tiny Tapeout's magic_init_project.tcl, unchanged
#   layout/tt_analog_1x2.def
#                         the 1x2 analog DEF template it reads
#   layout/UPSTREAM.md    where those two files came from
#   layout/build.tcl, layout/drc.tcl, layout/extract.tcl
#                         the course's scripts behind the make targets
#   layout/wires.tcl      what your layout adds to the frame (two stubs for now)
#   layout/README.md      what each file is for
# and adds layout/build/ to .gitignore. It never overwrites a file that exists.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TT_TOOLS="$(cd "$HERE/../common/tt-tools" && pwd)"
# shellcheck source=../common/tt-tools/pins.env
. "$TT_TOOLS/pins.env"
KIT_SRC="$TT_TOOLS/.local/tt-support-tools/tech/sky130A/def/analog"

die() { printf 'start.sh: %s\n' "$*" >&2; exit 1; }

[ $# -eq 1 ] || die "usage: ./start.sh <your repository folder>"
[ -d "$1" ] || die "no such folder: $1"
P="$(cd "$1" && pwd)"
[ -f "$P/info.yaml" ] && [ -f "$P/.github/workflows/gds.yaml" ] \
  || die "$P doesn't look like a repository made from the analog template (no info.yaml or .github/workflows/gds.yaml)"
grep -q 'custom_gds' "$P/.github/workflows/gds.yaml" \
  || die "$P/.github/workflows/gds.yaml doesn't call custom_gds, so it isn't the analog template's"
[ -f "$KIT_SRC/magic_init_project.tcl" ] \
  || die "the course tools aren't installed; run: make -C $TT_TOOLS install"

for f in Makefile layout/init.tcl layout/wires.tcl layout/build.tcl; do
  [ ! -e "$P/$f" ] || die "$P/$f already exists, so the kit is already there; nothing copied"
done

mkdir -p "$P/layout"
cp "$HERE/kit/Makefile" "$P/Makefile"
cp "$HERE/kit/layout/build.tcl" "$HERE/kit/layout/drc.tcl" "$HERE/kit/layout/extract.tcl" \
   "$HERE/kit/layout/wires.tcl" "$HERE/kit/layout/README.md" "$P/layout/"
cp "$KIT_SRC/magic_init_project.tcl" "$P/layout/init.tcl"
cp "$KIT_SRC/tt_analog_1x2.def" "$P/layout/tt_analog_1x2.def"

cat > "$P/layout/UPSTREAM.md" <<EOF
# Files copied from Tiny Tapeout

Two files in this folder are Tiny Tapeout's, copied without changes except for
the settings block of \`init.tcl\`, which the script asks you to edit.

| File here | Copied from |
|---|---|
| \`init.tcl\` | \`tech/sky130A/def/analog/magic_init_project.tcl\` |
| \`tt_analog_1x2.def\` | \`tech/sky130A/def/analog/tt_analog_1x2.def\` |

Source: https://github.com/TinyTapeout/tt-support-tools at commit
\`$TT_SUPPORT_TOOLS_COMMIT\`, the commit that precheck checked out on the
runner when IC102-A pinned its tools. tt-support-tools is licensed under
Apache-2.0, like this repository.

Copied by IC102-A Lab 01 (\`labs/lab-01-your-repo-from-the-template/start.sh\`
in https://github.com/uoftasic/ic102-a).
EOF

if ! grep -qx 'layout/build/' "$P/.gitignore" 2>/dev/null; then
  printf '\n# IC102-A: scratch output of make (the GDS and LEF go in gds/ and lef/)\nlayout/build/\n' >> "$P/.gitignore"
fi

echo "Added the IC102-A layout kit to $P:"
git -C "$P" status --short
