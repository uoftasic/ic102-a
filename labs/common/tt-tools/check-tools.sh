#!/usr/bin/env bash
# Print each tool precheck depends on: the version Tiny Tapeout's runner uses,
# the version installed here, and the version the workbench image has.
# Exits 1 if anything installed here differs from the pin, or is missing.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pins.env
. "$HERE/pins.env"
ROOT="${TT_TOOLS_ROOT:-$HERE/.local}"
unset PYTHONPATH KLAYOUT_PATH
export KLAYOUT_HOME="$ROOT/klayout-home"
mkdir -p "$KLAYOUT_HOME" 2>/dev/null

PY="$ROOT/venv/bin/python"
bad=0

first() { "$@" 2>/dev/null | head -1; }
pyver() { [ -x "$PY" ] && "$PY" -c "import importlib.metadata as m; print(m.version('$1'))" 2>/dev/null; }

# row TOOL PINNED HERE WORKBENCH [MATCH]
# MATCH is "exact" (default) or "minor" (compare the first two numbers only).
row() {
  local tool=$1 pinned=$2 here=$3 wb=$4 match=${5:-exact} status
  if [ -z "$here" ]; then
    status="MISSING"; bad=1
  elif [ "$match" = minor ] && [ "${here%.*}" = "${pinned%.*}" ]; then
    status="ok (${pinned%.*})"
  elif [ "$here" = "$pinned" ]; then
    status="ok"
  else
    status="DIFFERENT"; bad=1
  fi
  printf '%-18s %-20s %-20s %-20s %s\n' "$tool" "$pinned" "${here:--}" "${wb:--}" "$status"
}

short() { printf '%s' "${1:0:12}"; }
pdk_commit() { [ -f "$1/sky130A/SOURCES" ] && cut -d' ' -f2 "$1/sky130A/SOURCES" | head -1; }

echo "IC102-A tools: Tiny Tapeout's pins (tag $TT_ACTION_TAG) against this environment and the workbench"
echo "Installed in: $ROOT"
echo
printf '%-18s %-20s %-20s %-20s %s\n' "Tool" "Runner (pinned)" "Here" "Workbench" "Status"
printf '%-18s %-20s %-20s %-20s %s\n' "----" "---------------" "----" "---------" "------"

here_py=$([ -x "$PY" ] && "$PY" -c 'import platform; print(platform.python_version())')
row "Python" "$PYTHON_RUNNER" "$here_py" "$(python3 -c 'import platform; print(platform.python_version())' 2>/dev/null)" minor

here_magic=$([ -x "$ROOT/magic-$MAGIC_VERSION/bin/magic" ] && first "$ROOT/magic-$MAGIC_VERSION/bin/magic" --version)
row "Magic" "$MAGIC_VERSION" "$here_magic" "$(first /foss/tools/bin/magic --version)"

here_kl=$([ -x "$ROOT/bin/klayout" ] && first "$ROOT/bin/klayout" -b -v | sed 's/^KLayout //')
row "KLayout" "$KLAYOUT_VERSION" "$here_kl" "$(first /foss/tools/klayout/klayout -b -v | sed 's/^KLayout //')"

row "klayout (pip)" "$KLAYOUT_PY_VERSION" "$(pyver klayout)" "$(PYTHONPATH=/foss/tools/klayout/pymod python3 -c 'import klayout; print(klayout.__version__)' 2>/dev/null)"
row "gdstk (pip)" "0.9.52" "$(pyver gdstk)" "$(python3 -c 'import gdstk; print(gdstk.__version__)' 2>/dev/null)"
row "yowasp-yosys" "0.63.0.0.post1107" "$(pyver yowasp-yosys)" ""
row "ciel" "$CIEL_VERSION" "$(pyver ciel)" "$(first ciel --version | sed -n 's/^Ciel v\([^ ]*\).*/\1/p')"

row "sky130A PDK" "$(short "$SKY130_PDK_COMMIT")" "$(short "$(pdk_commit "$ROOT/pdk")")" "$(short "$(pdk_commit /foss/pdks)")"

here_tt=$([ -d "$ROOT/tt-support-tools/.git" ] && git -C "$ROOT/tt-support-tools" rev-parse HEAD 2>/dev/null)
row "tt-support-tools" "$(short "$TT_SUPPORT_TOOLS_COMMIT")" "$(short "$here_tt")" ""

echo
if [ $bad -eq 0 ]; then
  echo "All pinned tools are installed at the runner's versions."
else
  echo "Something is missing or different. Run 'make install', then check again."
fi
exit $bad
