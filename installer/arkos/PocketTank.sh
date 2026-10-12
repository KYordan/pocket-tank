#!/bin/sh
# EmulationStation port entry: launch outside its service cgroup so the game
# can claim the screen and controller, then restore the frontend on exit.
set -eu

APP_DIR=/home/ark/.local/share/pocket-tank
GAME_LAUNCHER="$APP_DIR/sim/run-r36s.sh"
if [ ! -x "$GAME_LAUNCHER" ]; then
    echo "Pocket Tank is not installed yet." >&2
    exit 1
fi

UNIT="pocket-tank-$(date +%s)-$$.service"
exec sudo -n systemd-run --quiet --no-block --collect \
    --unit="$UNIT" --uid=ark --setenv=HOME=/home/ark --nice=-19 \
    --working-directory="$APP_DIR/sim" "$GAME_LAUNCHER"
