#!/bin/sh
# Run Pocket Tank full-screen on ArkOS. EmulationStation holds the display and
# gamepad when it is active, so pause it while the simulator is running.
SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
cd "$SCRIPT_DIR" || exit 1

es_was_active=0
restore_frontend() {
    if [ "$es_was_active" -eq 1 ]; then
        sudo -n systemctl start emulationstation.service ||             echo "Could not restart EmulationStation; start it with sudo systemctl start emulationstation.service" >&2
        es_was_active=0
    fi
}
trap restore_frontend EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

if sudo -n systemctl is-active --quiet emulationstation.service; then
    es_was_active=1
    sudo -n systemctl stop emulationstation.service || exit 1
fi

./fishsim "$@"
status=$?
restore_frontend
trap - EXIT HUP INT TERM
exit "$status"
