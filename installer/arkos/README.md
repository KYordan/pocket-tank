# Pocket Tank for ArkOS

Unofficial community port by [KYordan](https://github.com/KYordan), based on
the upstream [Pocket Tank](https://github.com/mediacutlet/pocket-tank) project.
This port is not endorsed by the upstream author. See `PORTING-INFO.md` and
`THIRD-PARTY-LICENSES.txt` for attribution and license notes.

## Install the released package

This port targets **64-bit ARM ArkOS** on R36S / RG351MP-class handhelds. It
requires the EmulationStation **Ports** system, `systemd-run`, Python 3, and
passwordless `sudo`, which are provided by the supported ArkOS setup. The
installer is self-contained and does not need an internet connection.

1. Download `PocketTank-Installer.sh` from the
   [ArkOS Release](https://github.com/KYordan/pocket-tank/releases/tag/arkos-v1.0.0).
   Do not unpack or rename it.
2. Power off the handheld and put its game SD card in a computer. On the
   `EASYROMS` partition, copy the file into `roms/ports/`. The final path on the
   card should be `roms/ports/PocketTank-Installer.sh`.
3. Safely eject the card, put it back in the handheld, and start the device.
4. In EmulationStation, open **Ports** and select **Pocket Tank Installer**.
   Wait for the installer to finish and return to the menu; it adds **Pocket
   Tank** to Ports and removes its own installer entry.
5. Select **Pocket Tank** to play. Use the D-pad or left stick to move; press
   **A** or click the left stick to select. Hold **Start + Select** to save and
   exit back to EmulationStation.

The installer preserves an existing save at `~/.cache/pocket-tank/tank.sav`.
If installation fails, the device log is `/tmp/pocket-tank-install.log`.

## Build the installer from source

To rebuild the package, use a 64-bit ARM ArkOS console with the project source
and its build dependencies:

```sh
cd ~/projects/pocket-tank
tools/package_arkos.sh
```

The build creates `installer/dist/PocketTank-Installer.sh`. It can be
distributed as a GitHub Release asset using the player instructions above.
