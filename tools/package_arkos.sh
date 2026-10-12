#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
[ "$(uname -m)" = aarch64 ] || { echo 'Build this package on 64-bit ARM ArkOS.' >&2; exit 1; }
make -C "$ROOT/sim"
BIN="$ROOT/sim/fishsim"
[ -x "$BIN" ] || { echo 'sim/fishsim was not built.' >&2; exit 1; }
if command -v ldd >/dev/null 2>&1 && ldd "$BIN" 2>&1 | grep -q 'not found'; then
    echo 'Missing runtime library.' >&2
    exit 1
fi
STAGE=$(mktemp -d "${TMPDIR:-/tmp}/pocket-tank-package.XXXXXX")
trap 'rm -rf "$STAGE"' EXIT HUP INT TERM
mkdir -p "$STAGE/payload/app/sim" "$STAGE/payload/app/assets/sounds" \
    "$STAGE/payload/app/model/out" "$STAGE/payload/ports" "$STAGE/payload/installer/arkos"
install -m 755 "$BIN" "$STAGE/payload/app/sim/fishsim"
install -m 755 "$ROOT/sim/run-r36s.sh" "$STAGE/payload/app/sim/run-r36s.sh"
install -m 644 "$ROOT/assets/sounds/sounds.bin" "$STAGE/payload/app/assets/sounds/sounds.bin"
install -m 644 "$ROOT/model/out/model_q4.bin" "$STAGE/payload/app/model/out/model_q4.bin"
install -m 644 "$ROOT/model/out/tokenizer.bin" "$STAGE/payload/app/model/out/tokenizer.bin"
install -m 644 "$ROOT/LICENSE" "$STAGE/payload/app/LICENSE"
install -m 644 "$ROOT/installer/arkos/THIRD-PARTY-LICENSES.txt" "$STAGE/payload/app/THIRD-PARTY-LICENSES.txt"
install -m 644 "$ROOT/installer/arkos/PORTING-INFO.md" "$STAGE/payload/app/PORTING-INFO.md"
install -m 755 "$ROOT/installer/arkos/PocketTank.sh" "$STAGE/payload/ports/PocketTank.sh"
install -m 644 "$ROOT/installer/arkos/PocketTank-cover.svg" "$STAGE/payload/ports/PocketTank-cover.svg"
install -m 644 "$ROOT/installer/arkos/pocket-tank-gamelist.xml" "$STAGE/payload/ports/pocket-tank-gamelist.xml"
install -m 644 "$ROOT/installer/arkos/merge_gamelist.py" "$STAGE/payload/installer/arkos/merge_gamelist.py"
install -m 755 "$ROOT/installer/arkos/install_worker.sh" "$STAGE/payload/installer/arkos/install_worker.sh"
tar -czf "$STAGE/payload.tar.gz" -C "$STAGE" payload
mkdir -p "$ROOT/installer/dist"
cat "$ROOT/installer/arkos/self-extracting-installer.sh" "$STAGE/payload.tar.gz" > "$ROOT/installer/dist/PocketTank-Installer.sh"
chmod 755 "$ROOT/installer/dist/PocketTank-Installer.sh"
echo "Created $ROOT/installer/dist/PocketTank-Installer.sh"
