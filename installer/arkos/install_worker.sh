#!/bin/sh
# Runs in its own systemd service, outside EmulationStation's cgroup.
set -eu

SELF_PATH=${1:?installer path required}
TMP_ROOT=${2:?temporary directory required}
PAYLOAD="$TMP_ROOT/payload"
PORTS_DIR=/roms/ports
APP_DIR=/home/ark/.local/share/pocket-tank
LOG=/tmp/pocket-tank-install.log
ES_WAS_ACTIVE=0

case "$TMP_ROOT" in
    /tmp/pocket-tank-installer.*) ;;
    *) echo "Refusing unexpected temporary directory: $TMP_ROOT" >&2; exit 1 ;;
esac
exec >>"$LOG" 2>&1

finish() {
    status=$?
    trap - EXIT
    if [ "$ES_WAS_ACTIVE" -eq 1 ]; then
        sudo -n systemctl start emulationstation.service || \
            echo "Could not restart EmulationStation" >&2
    fi
    rm -rf "$TMP_ROOT"
    exit "$status"
}
trap finish EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

echo "Installing Pocket Tank for ArkOS..."
[ "$(uname -m)" = aarch64 ] || { echo "This package requires a 64-bit ARM ArkOS device."; exit 1; }
[ -d "$PORTS_DIR" ] || { echo "ArkOS Ports folder not found: $PORTS_DIR"; exit 1; }
grep -q '<name>ports</name>' /etc/emulationstation/es_systems.cfg || { echo "EmulationStation Ports system not found."; exit 1; }
[ -x "$PAYLOAD/app/sim/fishsim" ] || { echo "Pocket Tank executable is missing."; exit 1; }
[ -f "$PAYLOAD/app/assets/sounds/sounds.bin" ] || { echo "Sound data is missing."; exit 1; }
[ -f "$PAYLOAD/app/model/out/model_q4.bin" ] || { echo "Fish model is missing."; exit 1; }
[ -f "$PAYLOAD/app/model/out/tokenizer.bin" ] || { echo "Fish tokenizer is missing."; exit 1; }
[ -f "$PAYLOAD/ports/PocketTank.sh" ] || { echo "Ports launcher is missing."; exit 1; }
[ -f "$PAYLOAD/ports/PocketTank-cover.svg" ] || { echo "Pocket Tank artwork is missing."; exit 1; }
command -v systemd-run >/dev/null 2>&1 || { echo "systemd-run is required."; exit 1; }
sudo -n true || { echo "ArkOS passwordless sudo is required."; exit 1; }
if command -v ldd >/dev/null 2>&1 && ldd "$PAYLOAD/app/sim/fishsim" 2>&1 | grep -q 'not found'; then
    echo "A required ArkOS library is missing."; exit 1
fi

if sudo -n systemctl is-active --quiet emulationstation.service; then
    ES_WAS_ACTIVE=1
    sudo -n systemctl stop emulationstation.service || exit 1
fi

mkdir -p "$APP_DIR"
cp -a "$PAYLOAD/app/." "$APP_DIR/"
chmod 755 "$APP_DIR/sim/fishsim" "$APP_DIR/sim/run-r36s.sh"
install -m 644 "$PAYLOAD/ports/PocketTank-cover.svg" "$PORTS_DIR/PocketTank-cover.svg"

# Keep a one-time copy of any existing Ports metadata before merging ours.
if [ -f "$PORTS_DIR/gamelist.xml" ] && [ ! -e "$PORTS_DIR/.gamelist.xml.before-pocket-tank" ]; then
    cp -p "$PORTS_DIR/gamelist.xml" "$PORTS_DIR/.gamelist.xml.before-pocket-tank"
fi
GAMELIST_TMP="$PORTS_DIR/.gamelist.xml.pocket-tank.$$"
python3 "$PAYLOAD/installer/arkos/merge_gamelist.py" \
    "$PORTS_DIR/gamelist.xml" "$PAYLOAD/ports/pocket-tank-gamelist.xml" "$GAMELIST_TMP"
mv "$GAMELIST_TMP" "$PORTS_DIR/gamelist.xml"

LAUNCHER_TMP="$PORTS_DIR/.PocketTank.sh.$$"
install -m 755 "$PAYLOAD/ports/PocketTank.sh" "$LAUNCHER_TMP"
mv "$LAUNCHER_TMP" "$PORTS_DIR/PocketTank.sh"

# The installer entry is replaced by Pocket Tank after a successful install.
case "$SELF_PATH" in
    "$PORTS_DIR"/PocketTank-Installer.sh) rm -f "$SELF_PATH" ;;
esac
echo "Pocket Tank installed. The save in ~/.cache/pocket-tank is untouched."
