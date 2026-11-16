#!/usr/bin/env bash
# Run Tiny Tapeout's precheck on an analog project, the way the gds workflow
# runs it on GitHub: first the custom_gds job's copy into tt_submission/, then
# the precheck job's `python precheck.py --gds ... --tech sky130A`.
#
#   ./precheck.sh PROJECT_DIR      with the pinned tools in .local/
#   TT_TOOLSET=workbench ./precheck.sh PROJECT_DIR
#                                  the same checks, with the workbench's
#                                  Magic, KLayout and PDK
#
# PROJECT_DIR is your repository: it holds info.yaml, gds/<top_module>.gds,
# lef/<top_module>.lef and src/project.v. The script writes
# PROJECT_DIR/tt_submission/, which the template's .gitignore already ignores,
# and leaves the reports in PROJECT_DIR/tt_submission/precheck_reports/.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pins.env
. "$HERE/pins.env"
ROOT="${TT_TOOLS_ROOT:-$HERE/.local}"
TT_TOOLSET="${TT_TOOLSET:-pinned}"

die() { printf 'precheck.sh: %s\n' "$*" >&2; exit 2; }

[ $# -eq 1 ] || die "usage: ./precheck.sh PROJECT_DIR"
PROJECT="$(cd "$1" && pwd)" || die "no such folder: $1"
[ -f "$PROJECT/info.yaml" ] || die "$PROJECT has no info.yaml"
[ -x "$ROOT/venv/bin/python" ] && [ -f "$ROOT/tt-support-tools.ok" ] \
  || die "the tools aren't installed yet; run: make install"

# The runner has none of the workbench's settings, so start from a clean slate:
# the workbench's PYTHONPATH points at its own Python 3.12 packages (including
# KLayout 0.30.11's module), and KLAYOUT_PATH/KLAYOUT_HOME load its PDK setup.
unset PYTHONPATH KLAYOUT_PATH PDKPATH
export KLAYOUT_HOME="$ROOT/klayout-home"
mkdir -p "$KLAYOUT_HOME"

case "$TT_TOOLSET" in
  pinned)
    [ -f "$ROOT/magic.ok" ] && [ -f "$ROOT/klayout.ok" ] && [ -f "$ROOT/pdk.ok" ] \
      || die "Magic, KLayout or the PDK isn't installed yet; run: make install"
    export PATH="$ROOT/venv/bin:$ROOT/magic-$MAGIC_VERSION/bin:$ROOT/bin:/usr/bin:/bin"
    export PDK_ROOT="$ROOT/pdk"
    # The workbench's LD_LIBRARY_PATH starts with KLayout 0.30.11's libraries.
    unset LD_LIBRARY_PATH
    ;;
  workbench)
    export PATH="$ROOT/venv/bin:/foss/tools/bin:/foss/tools/klayout:/usr/bin:/bin"
    export PDK_ROOT=/foss/pdks
    ;;
  *) die "TT_TOOLSET must be 'pinned' or 'workbench', not '$TT_TOOLSET'" ;;
esac
export PDK=sky130A

TOP="$(python -c 'import sys, yaml; print(yaml.safe_load(open(sys.argv[1]))["project"]["top_module"])' "$PROJECT/info.yaml")"
for f in "gds/$TOP.gds" "lef/$TOP.lef" src/project.v; do
  [ -f "$PROJECT/$f" ] || die "$PROJECT/$f not found (top_module in info.yaml is '$TOP')"
done

# What custom_gds does before it uploads the tt_submission artifact. It also
# writes an .oas copy with KLayout 0.29.12, which precheck doesn't read.
SUB="$PROJECT/tt_submission"
rm -rf "$SUB"
mkdir -p "$SUB"
cp "$PROJECT/gds/$TOP.gds" "$SUB/$TOP.gds"
cp "$PROJECT/lef/$TOP.lef" "$SUB/$TOP.lef"
cp "$PROJECT/src/project.v" "$SUB/$TOP.v"
printf '{"PDK": "sky130A"}\n' > "$SUB/pdk.json"

echo "precheck: $TOP with the $TT_TOOLSET tools"
echo "  magic   $(command -v magic) ($(magic --version))"
echo "  klayout $(command -v klayout) ($(klayout -b -v))"
echo "  PDK     $PDK_ROOT/sky130A ($(cut -d' ' -f2 "$PDK_ROOT/sky130A/SOURCES" | head -1))"
echo

# What the precheck job runs, from tt-support-tools/precheck. Its reports
# folder is fixed, so empty it first, as a fresh runner would have it.
PRE="$ROOT/tt-support-tools/precheck"
find "$PRE/reports" -mindepth 1 ! -name .gitignore -delete
status=0
(cd "$PRE" && python precheck.py --gds "$SUB/$TOP.gds" --tech sky130A) || status=$?
cp -r "$PRE/reports" "$SUB/precheck_reports"
# The table the runner adds to the job summary ("Capture test results").
# precheck.py prints it itself when a check fails, so print it on a pass.
echo
if [ $status -eq 0 ]; then
  grep '^|' "$SUB/precheck_reports/results.md"
elif [ ! -f "$SUB/precheck_reports/results.md" ]; then
  echo "precheck.sh: precheck stopped before it wrote results.md"
fi
echo
echo "Reports: $SUB/precheck_reports/"
exit $status
