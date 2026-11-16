#!/usr/bin/env bash
# IC102-A Lab 05: precheck's first check, Magic DRC, on one GDS file.
#
#   ./magic-drc.sh GDS TOP_CELL REPORT_DIR
#
# Runs tt-support-tools' precheck/magic_drc.tcl, the script behind the "Magic
# DRC" row of precheck's table, with precheck's own Magic 8.3.568 and PDK from
# labs/common/tt-tools/.local. It writes two files into REPORT_DIR:
#
#   magic_drc.txt   the report precheck writes: each rule broken, the boxes
#                   where, and a line "[INFO]: COUNT: n"
#   magic.log       everything Magic printed while it worked
#
# and exits with Magic's own exit status, which is what precheck looks at:
# 0 when magic_drc.tcl found no errors, and 255 when it found some.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TT="$HERE/../common/tt-tools/.local"

[ $# -eq 3 ] || { echo "usage: magic-drc.sh GDS TOP_CELL REPORT_DIR" >&2; exit 2; }
GDS="$(realpath -m "$1")"
TOP_CELL="$2"
OUT="$(realpath -m "$3")"
MAGIC="$(ls -d "$TT"/magic-*/bin/magic 2>/dev/null | head -1)"
[ -x "$MAGIC" ] || { echo "magic-drc.sh: precheck's Magic isn't installed; run: make -C $HERE/../common/tt-tools install" >&2; exit 2; }

mkdir -p "$OUT"
cd "$TT/tt-support-tools/precheck"
env -u LD_LIBRARY_PATH PDK_ROOT="$TT/pdk" PDK=sky130A \
  "$MAGIC" -noconsole -dnull -rcfile "$TT/pdk/sky130A/libs.tech/magic/sky130A.magicrc" \
  magic_drc.tcl "$GDS" "$TOP_CELL" "$TT/pdk" "$OUT/magic_drc.txt" "$OUT/magic_drc.mag" \
  < /dev/null > "$OUT/magic.log" 2>&1
