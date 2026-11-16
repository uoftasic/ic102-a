#!/usr/bin/env bash
# Prove the install works: build the smallest layout that should pass
# precheck, from Tiny Tapeout's own analog kit, and run precheck on it.
#
# The layout is the analog template's empty 1x2 frame, made by the kit's
# magic_init_project.tcl (pins from tt_analog_1x2.def, VDPWR and VGND stripes
# on met4), plus a short met4 stub on ua[0] and on ua[1] so that the template's
# analog_pins: 2 is true. It is drawn with the workbench's Magic, as you would
# draw yours, and checked with the pinned tools, as the runner would check it.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pins.env
. "$HERE/pins.env"
ROOT="${TT_TOOLS_ROOT:-$HERE/.local}"
unset PYTHONPATH
W="$ROOT/selftest"
TOP=tt_um_ic102_selftest

rm -rf "$W" && mkdir -p "$W"
git init -q "$W"
git -C "$W" fetch -q --depth 1 "https://github.com/$TT_TEMPLATE" "$TT_TEMPLATE_COMMIT"
git -C "$W" -c advice.detachedHead=false checkout -q FETCH_HEAD

# info.yaml: our top module, and a description for the two pins we wire.
sed -i "s/top_module:  \"tt_um_example\"/top_module:  \"$TOP\"/; s/ua\[0\]: \"\"/ua[0]: \"stub\"/; s/ua\[1\]: \"\"/ua[1]: \"stub\"/" "$W/info.yaml"
sed -i "s/module tt_um_example/module $TOP/" "$W/src/project.v"

# The kit's script, with its settings block changed the way it asks you to.
KIT="$ROOT/tt-support-tools/tech/sky130A/def/analog"
cp "$KIT/tt_analog_1x2.def" "$W/"
sed "s/^set TOP_LEVEL_CELL .*/set TOP_LEVEL_CELL     $TOP/" "$KIT/magic_init_project.tcl" > "$W/init.tcl"
# Then the two stubs: met4 from the top edge of each pin (tech_data.py gives
# ua[0] at x = 151.81 um and ua[1] at x = 132.49 um, 0.9 um wide, 1 um tall).
cat > "$W/stubs.tcl" <<EOF
load $TOP
box 151.81um 1um 152.71um 10um
paint met4
box 132.49um 1um 133.39um 10um
paint met4
save $TOP.mag
gds write gds/$TOP.gds
lef write lef/$TOP.lef -hide -pinonly
EOF
(
  cd "$W"
  RC=/foss/pdks/sky130A/libs.tech/magic/sky130A.magicrc
  PDK_ROOT=/foss/pdks magic -dnull -noconsole -rcfile "$RC" init.tcl < /dev/null > magic-init.log 2>&1
  PDK_ROOT=/foss/pdks magic -dnull -noconsole -rcfile "$RC" stubs.tcl < /dev/null > magic-stubs.log 2>&1
)
[ -f "$W/gds/$TOP.gds" ] && [ -f "$W/lef/$TOP.lef" ] || { echo "selftest: Magic didn't write the layout; see $W/magic-*.log"; exit 1; }

"$HERE/precheck.sh" "$W"
