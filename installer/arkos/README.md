# Pocket Tank on another ArkOS console

Unofficial community port by [KYordan](https://github.com/KYordan), based on
the upstream [Pocket Tank](https://github.com/mediacutlet/pocket-tank) project.
This port is not endorsed by the upstream author. See `PORTING-INFO.md` and
`THIRD-PARTY-LICENSES.txt` for attribution and license notes.

Build the portable installer on the current 64-bit ARM ArkOS console:

```sh
cd ~/projects/pocket-tank
tools/package_arkos.sh
```

Copy `installer/dist/PocketTank-Installer.sh` to the other console's `/roms/ports/` folder, then select **Pocket Tank Installer** in EmulationStation Ports. The installer runs separately from EmulationStation, installs the app and artwork, adds the game entry while preserving the other Ports entries, then returns to EmulationStation. After installation, Pocket Tank appears in Ports and the installer entry removes itself.

In the game, hold **Start + Select** to save and exit. The installer leaves `~/.cache/pocket-tank/tank.sav` untouched. This package targets 64-bit ARM ArkOS with EmulationStation Ports, systemd, Python 3, and passwordless sudo; other firmware or 32-bit systems are not supported by this package.
