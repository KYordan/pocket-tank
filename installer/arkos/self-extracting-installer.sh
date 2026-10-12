#!/bin/sh
set -eu
SELF=$(readlink -f "$0")
if [ "${1-}" = --install-worker ]; then
    TMP_ROOT=$(mktemp -d /tmp/pocket-tank-installer.XXXXXX)
    ARCHIVE_LINE=$(awk '/^__POCKET_TANK_ARCHIVE_BELOW__$/ { print NR + 1; exit }' "$SELF")
    [ -n "$ARCHIVE_LINE" ] || { echo 'Installer archive marker is missing.' >&2; exit 1; }
    tail -n +"$ARCHIVE_LINE" "$SELF" | tar -xz -C "$TMP_ROOT"
    exec /bin/sh "$TMP_ROOT/payload/installer/arkos/install_worker.sh" "$SELF" "$TMP_ROOT"
fi
case "$SELF" in
    /roms/ports/PocketTank-Installer.sh) ;;
    *) echo 'Copy this installer to /roms/ports/PocketTank-Installer.sh first.' >&2; exit 1 ;;
esac
UNIT="pocket-tank-install-$(date +%s)-$$.service"
exec sudo -n systemd-run --quiet --no-block --collect --unit="$UNIT" --uid=ark \
    --setenv=HOME=/home/ark --working-directory=/roms/ports "$SELF" --install-worker
exit 0
__POCKET_TANK_ARCHIVE_BELOW__
