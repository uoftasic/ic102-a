#!/usr/bin/env bash
# Install Tiny Tapeout's precheck tools, at the versions precheck uses, inside
# the IIC-OSIC-TOOLS workbench. Everything goes under .local/ next to this
# file, which is on your own disk (/foss/designs is the workspace folder), so
# it survives a container restart and nothing in the image changes.
#
#   ./install.sh                 every part, in the order below
#   ./install.sh magic klayout   only those parts
#
# Parts: python  tt-support-tools  pdk  klayout  magic
# A part that finished before is skipped. Delete .local/<part>.ok to redo it.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=pins.env
. "$HERE/pins.env"
ROOT="${TT_TOOLS_ROOT:-$HERE/.local}"
mkdir -p "$ROOT/dl" "$ROOT/src" "$ROOT/bin"

# The workbench sets PYTHONPATH to its own Python 3.12 folders, and a 3.11
# interpreter that reads them breaks in confusing ways.
unset PYTHONPATH

PARTS=("$@")
[ ${#PARTS[@]} -gt 0 ] || PARTS=(python tt-support-tools pdk klayout magic)

log() { printf '\n== %s\n' "$*"; }
die() { printf 'install.sh: %s\n' "$*" >&2; exit 1; }

# fetch URL SHA256 FILE: download once, and refuse a file whose checksum differs.
fetch() {
  local url=$1 sha=$2 out=$3
  if [ -f "$out" ] && echo "$sha  $out" | sha256sum -c --status; then return 0; fi
  curl -fsSL --retry 3 -o "$out.part" "$url" || die "could not download $url"
  echo "$sha  $out.part" | sha256sum -c --status || die "checksum mismatch for $url"
  mv "$out.part" "$out"
}

done_already() { [ -f "$ROOT/$1.ok" ] && [ "$(cat "$ROOT/$1.ok")" = "$2" ]; }
mark_done() { echo "$2" > "$ROOT/$1.ok"; }

part_python() {
  local stamp="python $PYTHON_VERSION $(sha256sum "$HERE/requirements.txt" | cut -c1-12)"
  done_already python "$stamp" && { echo "python: already installed"; return; }
  command -v uv >/dev/null || die "uv not found; the workbench image ships it in /foss/tools/bin"
  export UV_PYTHON_INSTALL_DIR="$ROOT/python" UV_CACHE_DIR="$ROOT/cache/uv"
  uv python install "$PYTHON_VERSION"
  rm -rf "$ROOT/venv"
  uv venv --python "$PYTHON_VERSION" "$ROOT/venv"
  uv pip install --python "$ROOT/venv/bin/python" -r "$HERE/requirements.txt"
  uv cache clean >/dev/null 2>&1 || true
  mark_done python "$stamp"
}

part_tt_support_tools() {
  local dir="$ROOT/tt-support-tools"
  done_already tt-support-tools "$TT_SUPPORT_TOOLS_COMMIT" && { echo "tt-support-tools: already installed"; return; }
  rm -rf "$dir"
  git init -q "$dir"
  git -C "$dir" fetch -q --depth 1 "$TT_SUPPORT_TOOLS_REPO" "$TT_SUPPORT_TOOLS_COMMIT"
  git -C "$dir" -c advice.detachedHead=false checkout -q FETCH_HEAD
  [ "$(git -C "$dir" rev-parse HEAD)" = "$TT_SUPPORT_TOOLS_COMMIT" ] || die "tt-support-tools is not at $TT_SUPPORT_TOOLS_COMMIT"
  mark_done tt-support-tools "$TT_SUPPORT_TOOLS_COMMIT"
}

part_pdk() {
  done_already pdk "$SKY130_PDK_COMMIT" && { echo "pdk: already installed"; return; }
  [ -x "$ROOT/venv/bin/ciel" ] || die "run './install.sh python' first (ciel comes with it)"
  # The same command ciel-action runs on the runner.
  PDK_ROOT="$ROOT/pdk" "$ROOT/venv/bin/ciel" enable --pdk-root "$ROOT/pdk" --pdk sky130A "$SKY130_PDK_COMMIT"
  grep -q "$SKY130_PDK_COMMIT" "$ROOT/pdk/sky130A/SOURCES" || die "sky130A/SOURCES does not name $SKY130_PDK_COMMIT"
  # ciel unpacks both variants of the PDK. Precheck reads only sky130A, so
  # the 1.1 GB of sky130B can go.
  rm -rf "$ROOT/pdk/ciel/sky130/versions/$SKY130_PDK_COMMIT/sky130B" "$ROOT/pdk/sky130B"
  mark_done pdk "$SKY130_PDK_COMMIT"
}

part_klayout() {
  local dir="$ROOT/klayout-$KLAYOUT_VERSION" d
  done_already klayout "$KLAYOUT_VERSION" && { echo "klayout: already installed"; return; }
  fetch "$KLAYOUT_DEB_URL" "$KLAYOUT_DEB_SHA256" "$ROOT/dl/$(basename "$KLAYOUT_DEB_URL")"
  rm -rf "$dir"
  dpkg-deb -x "$ROOT/dl/$(basename "$KLAYOUT_DEB_URL")" "$dir"
  # Five Qt 5 libraries the KLayout package links against and the image
  # doesn't have. They're the Ubuntu 24.04 builds of the Qt the image has.
  while read -r url sha; do
    [ -n "$url" ] || continue
    d="$ROOT/dl/$(basename "$url")"
    fetch "$url" "$sha" "$d"
    dpkg-deb -x "$d" "$dir"
  done < "$HERE/klayout-qt-libs.txt"
  cat > "$ROOT/bin/klayout" <<EOF
#!/usr/bin/env bash
# KLayout $KLAYOUT_VERSION, unpacked from the Ubuntu 24.04 package (install.sh).
export LD_LIBRARY_PATH="$dir/usr/lib/klayout:$dir/usr/lib/x86_64-linux-gnu\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "$dir/usr/bin/klayout" "\$@"
EOF
  chmod +x "$ROOT/bin/klayout"
  "$ROOT/bin/klayout" -b -v | grep -q "KLayout $KLAYOUT_VERSION" || die "KLayout $KLAYOUT_VERSION doesn't start"
  mark_done klayout "$KLAYOUT_VERSION"
}

part_magic() {
  local src="$ROOT/src/magic-$MAGIC_VERSION" prefix="$ROOT/magic-$MAGIC_VERSION" dev="$ROOT/src/tcltk-dev"
  done_already magic "$MAGIC_VERSION" && { echo "magic: already installed"; return; }
  # Tcl and Tk headers: the libraries are in the image, the headers aren't.
  fetch "$TCL_DEV_DEB_URL" "$TCL_DEV_DEB_SHA256" "$ROOT/dl/$(basename "$TCL_DEV_DEB_URL")"
  fetch "$TK_DEV_DEB_URL" "$TK_DEV_DEB_SHA256" "$ROOT/dl/$(basename "$TK_DEV_DEB_URL")"
  rm -rf "$dev" && mkdir -p "$dev"
  dpkg-deb -x "$ROOT/dl/$(basename "$TCL_DEV_DEB_URL")" "$dev"
  dpkg-deb -x "$ROOT/dl/$(basename "$TK_DEV_DEB_URL")" "$dev"
  # The packages' tclConfig.sh and tkConfig.sh expect the stub libraries in
  # /usr/lib, where we can't write, so point those two lines at the copy.
  local lib="$dev/usr/lib/x86_64-linux-gnu"
  sed -i "s|-L/usr/lib/x86_64-linux-gnu -ltclstub|-L$lib -ltclstub|; s|'/usr/lib/x86_64-linux-gnu/libtclstub|'$lib/libtclstub|" "$lib/tcl8.6/tclConfig.sh"
  sed -i "s|-L/usr/lib/x86_64-linux-gnu -ltkstub|-L$lib -ltkstub|; s|'/usr/lib/x86_64-linux-gnu/libtkstub|'$lib/libtkstub|" "$lib/tk8.6/tkConfig.sh"
  # Magic's source at the tag precheck's nixpkgs builds, checked by commit.
  rm -rf "$src"
  git init -q "$src"
  git -C "$src" fetch -q --depth 1 https://github.com/RTimothyEdwards/magic "refs/tags/$MAGIC_VERSION"
  git -C "$src" -c advice.detachedHead=false checkout -q FETCH_HEAD
  [ "$(git -C "$src" rev-parse HEAD)" = "$MAGIC_TAG_COMMIT" ] || die "magic tag $MAGIC_VERSION is not commit $MAGIC_TAG_COMMIT"
  (
    cd "$src"
    ./configure --prefix="$prefix" \
      --with-tcl="$lib/tcl8.6" --with-tk="$lib/tk8.6" \
      --with-tclincls="$dev/usr/include/tcl8.6" --with-tkincls="$dev/usr/include/tcl8.6" \
      --with-tcllibs=/usr/lib/x86_64-linux-gnu --with-tklibs=/usr/lib/x86_64-linux-gnu \
      --disable-werror > "$ROOT/magic-configure.log" 2>&1 \
      || { tail -30 "$ROOT/magic-configure.log"; die "magic configure failed; see $ROOT/magic-configure.log"; }
    # Magic's Makefile generates database/database.h and compiles the modules
    # that include it as unordered prerequisites, so make the header first.
    { make database/database.h && make -j"$(nproc)"; } > "$ROOT/magic-build.log" 2>&1 \
      || { tail -30 "$ROOT/magic-build.log"; die "magic build failed; see $ROOT/magic-build.log"; }
    rm -rf "$prefix"
    make install >> "$ROOT/magic-build.log" 2>&1 || die "magic install failed; see $ROOT/magic-build.log"
  )
  # The image has no OpenGL headers, so this Magic has no 3D window, and
  # Magic 8.3.568 crashes at startup (a segfault in MacroDefine) when its
  # system .magicrc binds keys for that window ("macro wind3d ..."). Those 25
  # key bindings do nothing without the 3D window, so drop them.
  sed -i '/^macro wind3d /d' "$prefix/lib/magic/sys/.magicrc"
  "$prefix/bin/magic" --version | grep -qx "$MAGIC_VERSION" || die "the new magic doesn't report $MAGIC_VERSION"
  echo 'puts "magic starts"' > "$ROOT/magic-smoke.tcl"
  "$prefix/bin/magic" -dnull -noconsole -rcfile /dev/null "$ROOT/magic-smoke.tcl" < /dev/null 2>&1 | grep -q "magic starts" \
    || die "the new magic doesn't start in batch mode"
  rm -f "$ROOT/magic-smoke.tcl"
  rm -rf "$src" "$dev"
  mark_done magic "$MAGIC_VERSION"
}

for p in "${PARTS[@]}"; do
  log "$p"
  start=$SECONDS
  case "$p" in
    python) part_python ;;
    tt-support-tools) part_tt_support_tools ;;
    pdk) part_pdk ;;
    klayout) part_klayout ;;
    magic) part_magic ;;
    *) die "unknown part '$p' (python, tt-support-tools, pdk, klayout, magic)" ;;
  esac
  printf '%s: %d s\n' "$p" $((SECONDS - start))
done
rm -rf "$ROOT/cache" "$ROOT/dl"
log "done. Check with: make check-tools"
